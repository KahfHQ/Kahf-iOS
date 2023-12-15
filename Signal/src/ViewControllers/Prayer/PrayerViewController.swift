//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging
import SignalUI
import SnapKit
import UIKit
import CoreLocation
import Adhan    

enum PrayerContent {
    case runningPrayer(current: Prayer, next: Prayer, countdown: Date)
    case calendar(day: Day, city: String)
    case times(name: String, time: Date)
}

enum Day: CaseIterable {
    case yesterday
    case today
    case tomorrow
    
    var date: Date {
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        switch self {
        case .yesterday:
            return calendar.date(byAdding: .day, value: -1, to: now) ?? now
        case .today:
            return now
        case .tomorrow:
            return calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        }
    }
    
    var name: String {
        switch self {
        case .yesterday:
            return "Yesterday"
        case .today:
            return "Today"
        case .tomorrow:
            return "Tomorrow"
        }
    }
}

@objc
class PrayerViewController: UITableViewController {

    private var contents: [PrayerContent] = []
    var locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    var day : Day = .today
    
    private var customNavBar: KahfCustomNavBar = {
       let view = KahfCustomNavBar()
       return view
    }()
    
    @objc
    class func inModalNavigationController() -> OWSNavigationController {
        OWSNavigationController(rootViewController: PrayerViewController())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 22, leading: 0, bottom: 0, trailing: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ows_kahf_background
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAndRequestLocationAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSubviews()
        makeConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        customNavBar.removeFromSuperview()
    }
    
    func makeConstraints() {
        customNavBar.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
    }
    
    func addSubviews() {
        navigationController?.navigationBar.addSubview(customNavBar)
    }
    
    func fetchTimes(coordinate: CLLocationCoordinate2D) {
        contents.removeAll()
        getAddressFromCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude) { city in
            PrayerManager.shared.getCurrentNextPrayerTimes(coordinate: coordinate, completion: { current, next, countdown in
                guard let current = current, let next = next, let countdown = countdown else { return }
                self.contents.append(.runningPrayer(current: current, next: next, countdown: countdown))
                if let city = city {
                    self.contents.append(.calendar(day: self.day, city: city))
                }
                PrayerManager.shared.fetchTimes(coordinate: coordinate, day: self.day.date) { times in
                    guard let times = times else { return }
                    self.contents.append(.times(name: "Fajr", time: times.fajr))
                    self.contents.append(.times(name: "Sunrise", time: times.sunrise))
                    self.contents.append(.times(name: "Dhuhr", time: times.dhuhr))
                    self.contents.append(.times(name: "Asr", time: times.asr))
                    self.contents.append(.times(name: "Magrib", time: times.maghrib))
                    self.contents.append(.times(name: "Isha", time: times.isha))
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func checkAndRequestLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            let authorizationStatus = locationManager.authorizationStatus
            if !(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                startUpdatingLocation()
            }
        } else {
            print("Location services are not enabled.")
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = contents[indexPath.row]

        switch content {
            case .runningPrayer(let current, let next, let countdown):
                return RunningPrayerCell(reuseIdentifier: nil, current: PrayerManager.shared.getRawValue(prayer: current), next: PrayerManager.shared.getRawValue(prayer: next), coundown: countdown)
            case .calendar(let day, let city):
                let cell = CalendarCell(reuseIdentifier: nil, day: day, city: city)
                cell.leftButtonAction = { self.goToPrevDay() }
                cell.rightButtonAction = { self.goToNextDay() }
                return cell
            case .times(let name, let time):
                return TimeCell(reuseIdentifier: nil, name: name, time: time)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = contents[indexPath.row]

        switch content {
            case .runningPrayer: return 146
            case .calendar:  return 119
            case .times: return 70
        }
    }
    
    func goToPrevDay() {
        if day == .today {
            day = .yesterday
        } else if day == .tomorrow {
            day = .today
        }
        else {
            return
        }
        update()
    }
    
    func goToNextDay() {
        if day == .today {
            day = .tomorrow
        } else if day == .yesterday {
            day = .today
        }
        else {
            return
        }
        update()
    }
    
    func update() {
        guard let coordinate = coordinate else { return }
        self.fetchTimes(coordinate: coordinate)
    }
}

// MARK: - CLLocationManagerDelegate

extension PrayerViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        coordinate = location.coordinate
        fetchTimes(coordinate: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Show location page
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                startUpdatingLocation()
            case .denied, .restricted, .notDetermined:
                return //Show location page
            @unknown default:
                break
            }
    }
    
    func getAddressFromCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed with error: \(error.localizedDescription)")
                completion(nil)
            } else if let placemark = placemarks?.first {
                completion(placemark.administrativeArea ?? placemark.locality)
            } else {
                print("No placemarks available.")
                completion(nil)
            }
        }
    }
}
