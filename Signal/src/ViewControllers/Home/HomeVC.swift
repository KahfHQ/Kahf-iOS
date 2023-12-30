//
// Copyright 2023 Kahf Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging
import SignalUI
import SnapKit
import CoreLocation
import Adhan

enum HomeContent {
    case time(date: Date)
    case nextPrayer(prayer: Prayer, countdown: Date)
    case mosqueNearby
}

@objc
class HomeVC: UITableViewController {

    private var contents: [HomeContent] = []
    var locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    var day : Day = .today
    var prayerManager = PrayerManager.shared
    
    private var customNavBar: KahfCustomNavBar = {
       let view = KahfCustomNavBar()
       return view
    }()
    
    @objc
    class func inModalNavigationController() -> OWSNavigationController {
        OWSNavigationController(rootViewController: HomeVC())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ows_kahf_background
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAndRequestLocationAuthorization()
        self.contents.append(.time(date: Date()))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSubviews()
        makeConstraints()
        if let coordinate = coordinate {
            fetchTimes(coordinate: coordinate)
        }
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
        getAddressFromCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude) { city in
            self.contents.removeAll()
            self.prayerManager.getCurrentNextPrayerTimes(coordinate: coordinate, completion: { current, next, countdown in
                guard let next = next, let countdown = countdown else { return }
                self.contents.append(.nextPrayer(prayer: next, countdown: countdown))
                self.tableView.reloadData()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = contents[indexPath.row]

        switch content {
            case .time(let date): return DateCell(reuseIdentifier: nil, time: date)
            case .nextPrayer(let next, let nextPrayer): return NextPrayerTimeCell(reuseIdentifier: nil, next: next, nextPrayer: nextPrayer)
            case .mosqueNearby: return MosqueNearbyCell(reuseIdentifier: nil, time:Date())
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = contents[indexPath.row]

        switch content {
            case .time: return 56
            case .nextPrayer: return 243
            case .mosqueNearby: return 125
        }
    }
}
