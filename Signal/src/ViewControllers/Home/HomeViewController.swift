//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging
import SignalUI
import SnapKit

@objc
class HomeViewController: OWSTableViewController2 {

    @objc
    class func inModalNavigationController() -> OWSNavigationController {
        OWSNavigationController(rootViewController: HomeViewController())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
