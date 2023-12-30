//
// Copyright 2023 Kahf Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging
import SignalUI
import SnapKit

enum HomeContent {
    case time
    case nextPrayer
    case mosqueNearby
}

@objc
class HomeVC: UITableViewController {

    private var contents: [HomeContent] = [.time, .nextPrayer, .mosqueNearby]
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = contents[indexPath.row]

        switch content {
            case .time: return DateCell(reuseIdentifier: nil, time: Date())
            case .nextPrayer: return NextPrayerTimeCell(reuseIdentifier: nil, time: Date())
            case .mosqueNearby: return MosqueNearbyCell(reuseIdentifier: nil, time: Date())
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
