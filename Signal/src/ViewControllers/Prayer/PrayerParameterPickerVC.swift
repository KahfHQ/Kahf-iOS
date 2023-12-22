//
// Copyright 2023 Kahf Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//


import Foundation
import SignalMessaging
import SignalUI
import SnapKit
import UIKit
import CoreLocation
import Adhan

@objc
class PrayerParameterPickerVC: UITableViewController {

    private var contents: [PrayerContent] = []
    var day : Day = .today
    var prayerManager = PrayerManager.shared
    var calculationMethods : [CalculationMethod] = [.muslimWorldLeague, .egyptian, .karachi, .ummAlQura, .dubai, .moonsightingCommittee, .northAmerica, .kuwait, .qatar, .singapore, .tehran, .turkey, .other]
    var madhabs : [Madhab] = [.hanafi, .shafi]
    var isCalculationMethods: Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 22, leading: 0, bottom: 0, trailing: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ows_kahf_background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCalculationMethods ? calculationMethods.count : madhabs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isCalculationMethods {
            let cell = ParameterCell(reuseIdentifier: nil, name: calculationMethods[indexPath.row].stringFormat, isSelected: calculationMethods[indexPath.row] == prayerManager.params.method)
            return cell
        }
        else {
            let cell = ParameterCell(reuseIdentifier: nil, name:  madhabs[indexPath.row].stringFormat, isSelected: madhabs[indexPath.row] == prayerManager.params.madhab)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCalculationMethods {
            prayerManager.params.method = calculationMethods[indexPath.row]
        }
        else {
            prayerManager.params.madhab = madhabs[indexPath.row]
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension CalculationMethod {
    var stringFormat: String {
        switch self {
            case .muslimWorldLeague: return "Muslim World League"
            case .egyptian: return "Egyptian"
            case .karachi: return "Karachi"
            case .ummAlQura: return "Umm Al Qura"
            case .dubai: return "Dubai"
            case .moonsightingCommittee: return "Moon Sighting Committee"
            case .northAmerica: return "North America"
            case .kuwait: return "Kuwait"
            case .qatar: return "Qatar"
            case .singapore: return "Singapore"
            case .tehran: return "Tehran"
            case .turkey: return "Turkey"
            case .other: return "Other"
        }
    }
}

extension Madhab {
    var stringFormat: String {
        switch self {
            case .hanafi: return "Hanafi"
            case .shafi: return "Shafi"
        }
    }
}
