//
// Copyright 2023 Kahf Messenger
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

import Foundation

protocol GenderSettingsTableViewControllerDelegate: AnyObject {
    func genderDidChange(gender: String)
}

@objc
class GenderSettingsTableViewController: OWSTableViewController2 {
    var normalizedFamilyName = NSLocalizedString("PROFILE_GENDER_MALE_TEXT",comment: "Gender female text")
    private let originalFamilyName: String?
    var profileVC : ProfileSettingsViewController?
    private weak var genderSettingsDelegate: GenderSettingsTableViewControllerDelegate?

    required init(
        familyName: String?,
        genderSettingsDelegate: GenderSettingsTableViewControllerDelegate
    ) {
        self.originalFamilyName = familyName
        self.genderSettingsDelegate = genderSettingsDelegate

        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("PROFILE_GENDER_TITLE",comment: "Gender text")

        updateTableContents()
    }

    func updateTableContents() {
        let contents = OWSTableContents()

        let themeSection = OWSTableSection()
        themeSection.headerTitle = NSLocalizedString("PROFILE_GENDER_TITLE",comment: "Gender text")

        
        themeSection.add(appearanceItem(.female))
        themeSection.add(appearanceItem(.male))

        contents.addSection(themeSection)

        self.contents = contents
    }

    func appearanceItem(_ mode: Gender) -> OWSTableItem {
        return OWSTableItem(
            text: Self.nameForTheme(mode),
            actionBlock: { [weak self] in
                self?.normalizedFamilyName = GenderSettingsTableViewController.nameForTheme(mode)
                self?.changeTheme(mode)
                self?.genderSettingsDelegate?.genderDidChange(gender: self?.normalizedFamilyName ?? NSLocalizedString("PROFILE_GENDER_MALE_TEXT",comment: "Gender female text"))
            },
            accessoryType: normalizedFamilyName == GenderSettingsTableViewController.nameForTheme(mode) ? .checkmark : .none
        )
    }

    func changeTheme(_ mode: Gender) {
        updateTableContents()
    }

    static var currentThemeName: String {
        return nameForTheme(.male)
    }

    static func nameForTheme(_ mode: Gender) -> String {
        switch mode {
        case .female:
            return NSLocalizedString("PROFILE_GENDER_FEMALE_TEXT",comment: "Gender female text")
        case .male:
            return NSLocalizedString("PROFILE_GENDER_MALE_TEXT",comment: "Gender female text")
        }
    }

    @objc
    func didToggleAvatarPreference(_ sender: UISwitch) {
        Logger.info("Avatar preference toggled: \(sender.isOn)")
        SDSDatabaseStorage.shared.asyncWrite { writeTx in
            SSKPreferences.setPreferContactAvatars(sender.isOn, transaction: writeTx)
        }
    }
}

enum Gender {
    case female
    case male
}
