//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging
import SignalUI
import SnapKit
import UIKit
import CoreLocation
import Adhan
import PanModal

@objc
class AlarmNotificationOptionsVC: UIViewController {

    private var contents: [NotificationMethod] = [.silent, .notification, .adhan]
    var changeNotificationOption: ((_ method: NotificationMethod) -> Void)?
    var selectedMethod : NotificationMethod = .silent
    
    lazy var tableView: UITableView = {
       let view = UITableView()
       view.separatorStyle = .none
       view.rowHeight = UITableView.automaticDimension
       view.showsVerticalScrollIndicator = false
       view.backgroundColor = .white
       view.delegate = self
       view.dataSource = self
       return view
    }()
    
    lazy var titleSmall: UILabel = {
       let view = UILabel()
       view.font = UIFont.interMedium14
       view.textColor = UIColor.ows_gray01
       view.text = "Dhuhr Time"
       return view
    }()
    
    lazy var titleBig: UILabel = {
       let view = UILabel()
       view.font = UIFont.interBold24
       view.textColor = UIColor.ows_gray01
       view.text = "Adhan & Notification"
       return view
    }()
    
    lazy private var customDragLine: UIView = {
       let view = UIView()
       view.backgroundColor = .black
       view.layer.cornerRadius = 1.5
       view.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(3)
       }
       return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubview()
        makeConstraints()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func addSubview() {
        self.view.addSubview(customDragLine)
        self.view.addSubview(titleSmall)
        self.view.addSubview(titleBig)
        self.view.addSubview(tableView)
    }
    
    func makeConstraints() {
        customDragLine.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        titleSmall.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(29)
        }
        titleBig.snp.makeConstraints { make in
            make.top.equalTo(titleSmall.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(29)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleBig.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(255)
        }
    }
}

extension AlarmNotificationOptionsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NotificationTypeCell(reuseIdentifier: nil, method: contents[indexPath.row], isSelected: contents[indexPath.row] == selectedMethod)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeNotificationOption?(contents[indexPath.row])
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

public enum NotificationMethod: String {
    case silent = "Silent"
    case notification = "Notification"
    case adhan = "Adhan"
    
    var detail: String {
        switch self {
            case .silent: return "No notification & Adhan"
            case .notification: return "Notification message ( No Adhan) Only Beep"
            case .adhan: return "Full Adhan and notification both"
        }
    }
    
    var icon: UIImage {
        switch self {
            case .silent: return Theme.iconImage(.kahfAlertDisabled, renderingMode: .alwaysOriginal)
            case .notification: return Theme.iconImage(.kahfAlertNotif, renderingMode: .alwaysOriginal)
            case .adhan: return Theme.iconImage(.kahfAlertAdhan, renderingMode: .alwaysOriginal)
        }
    }
}

extension AlarmNotificationOptionsVC: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(386)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
    
    var showDragIndicator: Bool {
       return false
    }
}
