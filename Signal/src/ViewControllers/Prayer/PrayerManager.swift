//
// Copyright 2023 Kahf Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import Adhan
import CoreLocation

class PrayerManager {
    static let shared = PrayerManager()
    private var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    var params = CalculationMethod.moonsightingCommittee.params
    
    init() {
        calendar.timeZone = TimeZone.current
        params.madhab = .hanafi
        params.method = .muslimWorldLeague
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
            if let current = prayerTimes.currentPrayer(){
                if let next = prayerTimes.nextPrayer() {
                    completion(current, next, prayerTimes.time(for: next))
                } else if let prayerTimes = PrayerTimes(coordinates: coordinates, date: tomorrow, calculationParameters: params), let next = prayerTimes.nextPrayer() {
                    completion(current, next, prayerTimes.time(for: next))
                }
            }
        } else if let prayerTimes = PrayerTimes(coordinates: coordinates, date: tomorrow, calculationParameters: params) {
            if let current = prayerTimes.currentPrayer(), let next = prayerTimes.nextPrayer() {
                completion(current, next, prayerTimes.time(for: next))
            }
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
    
    func calculateNextPrayerTime(next: Prayer, date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date(), to: date)
        var labelText = ""
        if let hours = components.hour, let minutes = components.minute {
            
            
            if hours > 0 {
                labelText += "\(hours) hours"
            }
            
            if minutes > 0 {
                if labelText.count > 0 {
                    labelText += " "
                }
                labelText += "\(minutes) minutes"
            }
            
            if labelText.count > 0 {
                labelText += " until \(next)"
            } else {
                return "Event is happening now or in the past."
            }
        }
        return labelText
    }
    
    func calculateLeftTimeNextPrayerTime(next: Prayer, date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date(), to: date)
        var labelText = ""
        if let hours = components.hour, let minutes = components.minute {
            
            
            if hours > 0 {
                labelText += "\(hours) hours"
            }
            
            if minutes > 0 {
                if labelText.count > 0 {
                    labelText += " "
                }
                labelText += "\(minutes) minutes"
            }
            
            if labelText.count > 0 {
                labelText += " Left"
            } else {
                return "Event is happening now or in the past."
            }
        }
        return labelText
    }
}

