//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import CoreLocation

class MosqueNearbyManager {
    
    static let shared = MosqueNearbyManager()
   
    init() {
        
    }
    
    func getNearestMosque(coordinate: CLLocationCoordinate2D, completion: @escaping(Mosque?) -> Void) -> Void {
        let url = URL(string: "https://api.prayersconnect.com/mosques.json?=&distance=5&lat=\(coordinate.latitude)&long=\(coordinate.longitude)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.setValue("Bearer wGYkQ5mjUNEZfgBbCy3sGW9GoG3QGuw7QEv2DPiC2FU", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            // Parse and handle the data as needed
            do {
                let decoder = JSONDecoder()
                let mosqueResponse = try decoder.decode(MosqueNearbyResponse.self, from: data)

                // Access the decoded data
                if let mosques = mosqueResponse.mosques, var firstMosque = mosques.first {
                    if let mosqueAddress = firstMosque.address {
                        self.geocodeAddressString(mosqueAddress) { mosqueCoordinate, error in
                            if let mosqueCoordinate = mosqueCoordinate {
                                let distance = self.calculateDistance(from: coordinate, to: mosqueCoordinate)
                                firstMosque.mosqueCoordinate = mosqueCoordinate
                                let distanceString = String(format: NSLocalizedString("KAHF_DISTANCE_FROM_LOCATION", comment: ""),  String(format: "%.2f", distance))
                                firstMosque.distanceString = distanceString
                            }
                            completion(firstMosque)
                        }
                    }
                    else {
                        completion(firstMosque)
                    }
                } else {
                    completion(nil)
                }
                
            } catch {
                completion(nil)
            }
        }

        task.resume()
    }
    
    func geocodeAddressString(_ address: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            if let placemark = placemarks?.first {
                let coordinates = placemark.location?.coordinate
                completion(coordinates, nil)
            } else {
                completion(nil, NSError(domain: "YourAppDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No coordinates found for the given address."]))
            }
        }
    }
    
    func calculateDistance(from coordinate1: CLLocationCoordinate2D, to coordinate2: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)

        // Calculate the distance in meters
        let distanceInMeters = location1.distance(from: location2)

        // Convert the distance to kilometers
        let distanceInKilometers = distanceInMeters / 1000.0

        return distanceInKilometers
    }

}

// MARK: - MosqueNearbyResponse

struct MosqueNearbyResponse: Codable {
    let total: Int?
    let mosques: [Mosque]?
}

// MARK: - Mosque
struct Mosque: Codable {
    let id: Int?
    let name, nativeName: String?
    let address: String?
    let provinceID: Int?
    let zipcode, city: String?
    let countryID: Int?
    let hidden: Bool?
    var mosqueCoordinate: CLLocationCoordinate2D?
    var distanceString: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case nativeName = "nativeName"
        case address, provinceID
        case zipcode, city
        case countryID, hidden
    }
}

