//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

struct CDSRegisteredContact: Hashable {
    let signalUuid: UUID
    let e164PhoneNumber: E164
}

/// Fetches contact info from the ContactDiscoveryService
/// Intended to be used by ContactDiscoveryTaskQueue. You probably don't want to use this directly.
class SGXContactDiscoveryOperation: ContactDiscoveryOperation {
    static let batchSize = 2048

    private let e164sToLookup: Set<E164>
    required init(e164sToLookup: Set<E164>, mode: ContactDiscoveryMode) {
        self.e164sToLookup = e164sToLookup
        Logger.debug("with e164sToLookup.count: \(e164sToLookup.count)")
    }

    func perform(on queue: DispatchQueue) -> Promise<Set<DiscoveredContactInfo>> {
        firstly { () -> Promise<[Set<CDSRegisteredContact>]> in
            // First, build a bunch of batch Promises
            let batchOperationPromises = Array(e164sToLookup)
                .chunked(by: Self.batchSize)
                .map { makeContactDiscoveryRequest(e164sToLookup: Array($0)) }

            // Then, wait for them all to be fulfilled before joining the subsets together
            return Promise.when(fulfilled: batchOperationPromises)

        }.map(on: queue) { (setArray) -> Set<DiscoveredContactInfo> in
            setArray.reduce(into: Set()) { (builder, cdsContactSubset) in
                builder.formUnion(cdsContactSubset.map {
                    DiscoveredContactInfo(e164: $0.e164PhoneNumber, uuid: $0.signalUuid)
                })
            }
        }.recover(on: queue) { error -> Promise<Set<DiscoveredContactInfo>> in
            throw Self.prepareExternalError(from: error)
        }
    }

    // Below, we have a bunch of then blocks being performed on a global concurrent queue
    // It might be worthwhile to audit and see if we can move these onto the queue passed into `perform(on:)`

    private func makeContactDiscoveryRequest(e164sToLookup: [E164]) -> Promise<Set<CDSRegisteredContact>> {
        firstly { () -> Promise<RemoteAttestation.CDSAttestation> in
            RemoteAttestation.performForCDS()

        }.then(on: DispatchQueue.global()) { (attestation: RemoteAttestation.CDSAttestation) -> Promise<(RemoteAttestation.CDSAttestation, ContactDiscoveryService.IntersectionResponse)> in
            let service = ContactDiscoveryService()
            let query = try self.buildIntersectionQuery(e164sToLookup: e164sToLookup,
                                                        remoteAttestations: attestation.remoteAttestations)
            return service.getRegisteredSignalUsers(
                query: query,
                cookies: attestation.cookies,
                authUsername: attestation.auth.username,
                authPassword: attestation.auth.password,
                enclaveName: attestation.enclaveConfig.enclaveName,
                host: attestation.enclaveConfig.host,
                censorshipCircumventionPrefix: attestation.enclaveConfig.censorshipCircumventionPrefix
            ).map {(attestation, $0)}

        }.map(on: DispatchQueue.global()) { attestation, response -> Set<CDSRegisteredContact> in
            let allEnclaveAttestations = attestation.remoteAttestations
            let respondingEnclaveAttestation = allEnclaveAttestations.first(where: { $1.requestId == response.requestId })

            guard let responseAttestion = respondingEnclaveAttestation?.value else {
                throw ContactDiscoveryError.assertionError(description: "Invalid responding enclave for requestId: \(response.requestId)")
            }

            let plaintext = try Aes256GcmEncryptedData(
                nonce: response.iv,
                ciphertext: response.data,
                authenticationTag: response.mac
            ).decrypt(key: responseAttestion.keys.serverKey.keyData)

            // 16 bytes per UUID
            let contactCount = UInt(e164sToLookup.count)
            guard plaintext.count == contactCount * 16 else {
                throw ContactDiscoveryError.assertionError(description: "failed check: invalid byte count")
            }
            let dataParser = OWSDataParser(data: plaintext)
            let uuidsData = try dataParser.nextData(length: contactCount * 16, name: "uuids")

            guard dataParser.isEmpty else {
                throw ContactDiscoveryError.assertionError(description: "failed check: dataParse.isEmpty")
            }

            let uuids = type(of: self).uuidArray(from: uuidsData)

            guard uuids.count == contactCount else {
                throw ContactDiscoveryError.assertionError(description: "failed check: uuids.count == contactCount")
            }

            let unregisteredUuid = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))

            var registeredContacts: Set<CDSRegisteredContact> = Set()

            for (index, e164PhoneNumber) in e164sToLookup.enumerated() {
                let uuid = uuids[index]
                guard uuid != unregisteredUuid else {
                    Logger.verbose("not a signal user: \(e164PhoneNumber)")
                    continue
                }

                Logger.verbose("Signal user. e164: \(e164PhoneNumber), uuid: \(uuid)")
                registeredContacts.insert(CDSRegisteredContact(signalUuid: uuid, e164PhoneNumber: e164PhoneNumber))
            }

            return registeredContacts
        }
    }

    func buildIntersectionQuery(e164sToLookup: [E164], remoteAttestations: [RemoteAttestation.CDSAttestation.Id: RemoteAttestation]) throws -> ContactDiscoveryService.IntersectionQuery {
        let noncePlainTextData = Randomness.generateRandomBytes(32)
        let addressPlainTextData = ContactDiscoveryE164Collection(e164sToLookup).encodedValues
        let queryData = Data.join([noncePlainTextData, addressPlainTextData])

        let key = OWSAES256Key.generateRandom()
        let encryptionResult = try Aes256GcmEncryptedData.encrypt(queryData, key: key.keyData)
        assert(encryptionResult.ciphertext.count == e164sToLookup.count * 8 + 32)

        let queryEnvelopes: [RemoteAttestation.CDSAttestation.Id: ContactDiscoveryService.IntersectionQuery.EnclaveEnvelope] = try remoteAttestations.mapValues { remoteAttestation in
            let perEnclaveKey = try Aes256GcmEncryptedData.encrypt(
                key.keyData,
                key: remoteAttestation.keys.clientKey.keyData,
                associatedData: remoteAttestation.requestId
            )

            return ContactDiscoveryService.IntersectionQuery.EnclaveEnvelope(
                requestId: remoteAttestation.requestId,
                data: perEnclaveKey.ciphertext,
                iv: perEnclaveKey.nonce,
                mac: perEnclaveKey.authenticationTag
            )
        }

        guard let commitment = Cryptography.computeSHA256Digest(queryData) else {
            throw ContactDiscoveryError.assertionError(description: "commitment was unexpectedly nil")
        }

        return ContactDiscoveryService.IntersectionQuery(
            addressCount: UInt(e164sToLookup.count),
            commitment: commitment,
            data: encryptionResult.ciphertext,
            iv: encryptionResult.nonce,
            mac: encryptionResult.authenticationTag,
            envelopes: queryEnvelopes
        )
    }

    class func uuidArray(from data: Data) -> [UUID] {
        // Ensure that the data length is a multiple of the UUID size
        guard data.count % MemoryLayout<uuid_t>.size == 0 else {
            return [] // The data length is not a multiple of the UUID size
        }

        return data.withUnsafeBytes { (pointer: UnsafePointer<uuid_t>) in
            let count = data.count / MemoryLayout<uuid_t>.size
            let buffer = UnsafeBufferPointer(start: pointer, count: count)
            return Array(buffer).map { UUID(uuid: $0) }
        }
    }

    /// Parse the error and, if appropriate, construct an error appropriate to return upwards
    /// May return the provided error unchanged.
    class func prepareExternalError(from error: Error) -> Error {
        // Network connectivity failures should never be re-wrapped
        if error.isNetworkConnectivityFailure {
            return error
        }

        let retryAfterDate = error.httpRetryAfterDate.map { min($0, Date(timeIntervalSinceNow: 60 * kMinuteInterval)) }

        if let statusCode = error.httpStatusCode {
            switch statusCode {
            case 401:
                return ContactDiscoveryError(
                    kind: .unauthorized,
                    debugDescription: "User is unauthorized",
                    retryable: false,
                    retryAfterDate: retryAfterDate)
            case 404:
                return ContactDiscoveryError(
                    kind: .unexpectedResponse,
                    debugDescription: "Unknown enclaveID",
                    retryable: false,
                    retryAfterDate: retryAfterDate)
            case 408:
                return ContactDiscoveryError(
                    kind: .timeout,
                    debugDescription: "Server rejected due to a timeout",
                    retryable: true,
                    retryAfterDate: retryAfterDate)
            case 409:
                // Conflict on a discovery request indicates that the requestId specified by the client
                // has been dropped due to a delay or high request rate since the preceding corresponding
                // attestation request. The client should not retry the request automatically
                return ContactDiscoveryError(
                    kind: .genericClientError,
                    debugDescription: "RequestID conflict",
                    retryable: false,
                    retryAfterDate: retryAfterDate)
            case 429:
                return ContactDiscoveryError(
                    kind: .rateLimit,
                    debugDescription: "Rate limit",
                    retryable: true,
                    retryAfterDate: retryAfterDate)
            case 400..<500:
                return ContactDiscoveryError(
                    kind: .genericClientError,
                    debugDescription: "Client error (\(statusCode)): \(error.userErrorDescription)",
                    retryable: false,
                    retryAfterDate: retryAfterDate)
            case 500..<600:
                return ContactDiscoveryError(
                    kind: .genericServerError,
                    debugDescription: "Server error (\(statusCode)): \(error.userErrorDescription)",
                    retryable: true,
                    retryAfterDate: retryAfterDate)
            default:
                return ContactDiscoveryError(
                    kind: .generic,
                    debugDescription: "Unknown error (\(statusCode)): \(error.userErrorDescription)",
                    retryable: false,
                    retryAfterDate: retryAfterDate)
            }

        } else {
            return error
        }
    }
}
