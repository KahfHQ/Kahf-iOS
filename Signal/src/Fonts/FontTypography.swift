//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import UIKit

extension UIFont {
    enum Typography {
        static let bold14 = UIFont(name: "Inter-Bold", size: 14) ?? .boldSystemFont(ofSize: 14)
        static let semiBold12 = UIFont(name: "Inter-SemiBold", size: 12) ?? .ows_semiboldFont(withSize: 12)
    }
}
