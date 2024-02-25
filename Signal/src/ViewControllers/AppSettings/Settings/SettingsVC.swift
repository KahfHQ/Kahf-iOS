//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import UIKit
import SignalMessaging
import SignalUI

class SettingsVC: UITableViewController {

    private var contents: [[AppSetting]] = []
    private var customLeftView: UIView?
    
    enum AppSetting: String {
        case profile = "SETTINGS_PROFILE"
        case account = "SETTINGS_ACCOUNT"
        case linkedDevices = "LINKED_DEVICES_TITLE"
        case appearance = "SETTINGS_APPEARANCE_TITLE"
        case chats = "SETTINGS_CHATS"
        case notifications = "SETTINGS_NOTIFICATIONS"
        case privacy = "SETTINGS_PRIVACY_TITLE"
        case dataUsage =  "SETTINGS_DATA"
        case help = "SETTINGS_HELP"
        case internalSettings = "Internal"
        //case stories = "STORY_SETTINGS_TITLE"
        //case invite(InviteViewController) // Replace with your specific InviteViewController type

        var viewController: UIViewController {
            switch self {
            case .profile: return ProfileSettingsViewController()
            case .account: return AccountSettingsViewController()
            case .linkedDevices: return LinkedDevicesTableViewController()
            case .appearance: return AppearanceSettingsTableViewController()
            case .chats: return ChatsSettingsViewController()
            case .notifications: return NotificationSettingsViewController()
            case .privacy: return PrivacySettingsViewController()
            case .dataUsage: return DataSettingsTableViewController()
            case .help: return HelpViewController()
            case.internalSettings: return InternalSettingsViewController()
            //case .stories: return ChatsSettingsViewController()
            //case .invite: return
            }
        }
        
        var icon: UIImage {
            switch self {
            case .profile: return UIImage()
            case .account: return Theme.iconImage(.kahfSettingsAccounts, renderingMode: .alwaysOriginal)
            case .linkedDevices: return Theme.iconImage(.kahfSettingsLinkedDevice, renderingMode: .alwaysOriginal)
            case .appearance: return Theme.iconImage(.kahfSettingsAppearance, renderingMode: .alwaysOriginal)
            case .chats: return Theme.iconImage(.kahfSettingsChat, renderingMode: .alwaysOriginal)
            case .notifications: return Theme.iconImage(.kahfSettingsNotifications, renderingMode: .alwaysOriginal)
            case .privacy: return Theme.iconImage(.kahfSettingsPrivacy, renderingMode: .alwaysOriginal)
            case .dataUsage: return Theme.iconImage(.kahfSettingsData, renderingMode: .alwaysOriginal)
            case .help: return Theme.iconImage(.kahfSettingsHelp, renderingMode: .alwaysOriginal)
            case.internalSettings: return Theme.iconImage(.settingsAdvanced, renderingMode: .alwaysOriginal)
            //case .stories: return Theme.iconImage(.kahfHomeIcon, renderingMode: .alwaysOriginal)
            //case .invite: return
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0
        navigationItem.hidesBackButton = true
        updateTableContents()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localProfileDidChange),
            name: .localProfileDidChange,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hasExpiredGiftBadgeDidChange),
            name: .hasExpiredGiftBadgeDidChangeNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomizedBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.customLeftView?.removeFromSuperview()
        self.customLeftView = nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents[section].count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = contents[indexPath.section][indexPath.row]

        switch setting {
            case .profile: return profileCell()
            default: return settingsCell(title: setting.rawValue, icon: setting.icon)
            /*case .stories:
                if RemoteConfig.stories {
                    return settingsCell(title: setting.rawValue, icon: setting.icon)
                }
            */
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = contents[indexPath.section][indexPath.row]
        self.navigationController?.pushViewController(setting.viewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        else {
            let headerView = UIView()
            let line = UIView()
            line.backgroundColor = .black
            line.alpha = 0.05
            headerView.addSubview(line)
            line.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.leading.trailing.equalToSuperview().inset(30)
                make.centerY.equalToSuperview()
            }
            return headerView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let setting = contents[indexPath.section][indexPath.row]
        switch setting {
            case .profile: return 88
            default: return 54
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 13
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return " " }
    
    private func profileCell() -> UITableViewCell {
        let cell = SettingsProfileCell(reuseIdentifier: nil)
        return cell
    }

    private func settingsCell(title: String, icon: UIImage) -> SettingsCell {
        return SettingsCell(title: title, iconImage: icon, reuseIdentifier: nil)
    }

    // MARK: - Notification Observers

    @objc private func localProfileDidChange() {
        
    }

    @objc private func hasExpiredGiftBadgeDidChange() {
        
    }
    
    func setCustomizedBackButton() {
        if customLeftView == nil {
            let customView = UIView(frame: CGRect(x: 0, y: 13, width: 138, height: 19))
            customView.backgroundColor = UIColor.clear
            let backButton = UIButton(type: .custom)
            backButton.setImage(Theme.iconImage(.kahfBackIcon, renderingMode: .alwaysOriginal), for: .normal)
            backButton.imageView?.contentMode = .scaleAspectFit
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            customView.addSubview(backButton)
            backButton.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalToSuperview().offset(23)
                make.width.equalTo(23)
                make.height.equalTo(18)
            }
            let title = UILabel()
            title.text = NSLocalizedString("SETTINGS_NAV_BAR_TITLE", comment: "Title for settings activity")
            title.font = UIFont.interBold16
            title.textColor = UIColor.ows_gray01
            customView.addSubview(title)
            title.snp.makeConstraints { make in
                make.leading.equalTo(backButton.snp.trailing).offset(12)
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalTo(19)
            }
            customLeftView = customView
            navigationController?.navigationBar.addSubview(customView)
        }
    }
    
    @objc func backButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    func updateTableContents() {
      contents = [
           [.profile],
           [.account, .linkedDevices],
           [.appearance, .chats, .notifications, .privacy, .dataUsage],
           [.help],
       ]

       if DebugFlags.internalSettings {
           contents.append([.internalSettings])
       }

       tableView.reloadData()
    }
}
