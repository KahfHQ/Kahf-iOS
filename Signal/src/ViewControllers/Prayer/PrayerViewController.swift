//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging
import SignalUI
import SnapKit

@objc
class PrayerViewController: OWSTableViewController2 {

    @objc
    class func inModalNavigationController() -> OWSNavigationController {
        OWSNavigationController(rootViewController: PrayerViewController())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
