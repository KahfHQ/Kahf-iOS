//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import Adhan
import CoreLocation

class PrayerManager {
    static let shared = PrayerManager()
    private var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    private var params = CalculationMethod.moonsightingCommittee.params
    
    init() {
        calendar.timeZone = TimeZone.current
        params.madhab = .hanafi
    }
    
    func fetchTimes(coordinate: CLLocationCoordinate2D, day: Date, completion: @escaping(PrayerTimes?) -> Void) -> Void {
        if let prayerTimes = PrayerTimes(coordinates: Coordinates(latitude: coordinate.latitude, longitude: coordinate.longitude), date: calendar.dateComponents([.year, .month, .day], from: day), calculationParameters: params) {
            completion(prayerTimes)
        }
        else {
            completion(nil)
        }
    }
    
    func getCurrentNextPrayerTimes(coordinate: CLLocationCoordinate2D, completion: @escaping(Prayer?, Prayer?, Date?) -> Void) -> Void {
        let coordinates = Coordinates(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let today = calendar.dateComponents([.year, .month, .day], from: Day.today.date)
        let tomorrow = calendar.dateComponents([.year, .month, .day], from: Day.tomorrow.date)
        if let prayerTimes = PrayerTimes(coordinates: coordinates, date: today, calculationParameters: params) {
            guard let current = prayerTimes.currentPrayer(), let next = prayerTimes.nextPrayer() else { return }
            completion(current, next, prayerTimes.time(for: next))
            
        } else if let prayerTimes = PrayerTimes(coordinates: coordinates, date: tomorrow, calculationParameters: params) {
            guard let current = prayerTimes.currentPrayer(), let next = prayerTimes.nextPrayer() else { return }
            completion(current, next, prayerTimes.time(for: next))
        }
        else {
            completion(nil, nil, nil)
        }
    }
    
    func getRawValue(prayer: Prayer) -> String{
        switch prayer {
        case .fajr:
            return "Fajr"
        case .sunrise:
            return "Sunrise"
        case .dhuhr:
            return "Dhuhr"
        case .asr:
            return "Asr"
        case .maghrib:
            return "Maghrib"
        case .isha:
            return "Isha"
        }
    }
}

