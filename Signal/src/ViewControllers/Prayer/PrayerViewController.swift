//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging
import SignalUI
import SnapKit
import UIKit

enum PrayerContent {
    case runningPrayer
    case calendar
    case times
}

@objc
class PrayerViewController: UITableViewController {

    private var contents: [PrayerContent] = []
    
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
        fetchTimes()
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
    
    func fetchTimes() {
        contents.append(.runningPrayer)
        contents.append(.calendar)
        contents.append(.times)
        contents.append(.times)
        contents.append(.times)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = contents[indexPath.row]

        switch content {
            case .runningPrayer: return RunningPrayerCell(reuseIdentifier: nil)
            case .calendar: return CalendarCell(reuseIdentifier: nil)
            case .times: return TimeCell(reuseIdentifier: nil)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let setting = contents[indexPath.row]
        //self.navigationController?.pushViewController(setting.viewController, animated: true)
    }
}
