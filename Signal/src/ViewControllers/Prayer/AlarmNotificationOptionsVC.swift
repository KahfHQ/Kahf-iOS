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
    
    lazy var titleBig: UILabel = {
       let view = UILabel()
       view.font = UIFont.interBold24
       view.textColor = UIColor.ows_gray01
       view.text =  OWSLocalizedString("KAHF_ADHAN_NOTIFICATION", comment: "")
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
        self.view.addSubview(titleBig)
        self.view.addSubview(tableView)
    }
    
    func makeConstraints() {
        customDragLine.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        titleBig.snp.makeConstraints { make in
            make.top.equalTo(customDragLine.snp.bottom).offset(7)
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

public enum NotificationMethod {
    case silent
    case notification
    case adhan
    
    var detail: String {
        switch self {
            case .silent: return OWSLocalizedString("KAHF_NO_NOTIFICATION_ADHAN", comment: "")
            case .notification: return OWSLocalizedString("KAHF_NOTIFICATION_MESSAGE", comment: "")
            case .adhan: return OWSLocalizedString("KAHF_FULL_ADHAN_NOTIFICATION", comment: "")
        }
    }
    
    var title: String {
        switch self {
            case .silent: return OWSLocalizedString("KAHF_SILENT", comment: "")
            case .notification: return OWSLocalizedString("KAHF_NOTIFICATION", comment: "")
            case .adhan:  return OWSLocalizedString("KAHF_ADHAN", comment: "")
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
