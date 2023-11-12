//
// Copyright 2023 Kahf Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import UIKit

@objc
public extension UIFont {
    @objc(interBold14)
    class var interBold14: UIFont {
        UIFont(name: "Inter-Bold", size: 14) ?? .boldSystemFont(ofSize: 14)
    }
    
    @objc(interBold16)
    class var interBold16: UIFont {
        UIFont(name: "Inter-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
    }
    
    @objc(interSemiBold12)
    class var interSemiBold12: UIFont {
        return UIFont(name: "Inter-SemiBold", size: 12) ?? .ows_semiboldFont(withSize: 12)
    }
    
    @objc(interSemiBold16)
    class var interSemiBold16: UIFont {
        return UIFont(name: "Inter-SemiBold", size: 16) ?? .ows_semiboldFont(withSize: 16)
    }

    
    @objc(interRegular12)
    class var interRegular12: UIFont {
        return UIFont(name: "Inter-Regular", size: 12) ?? .ows_regularFont(withSize: 12)
    }
    
    @objc(interRegular16)
    class var interRegular16: UIFont {
        return UIFont(name: "Inter-Regular", size: 16) ?? .ows_regularFont(withSize: 16)
    }
    
    @objc(interMedium11)
    class var interMedium11: UIFont {
        return UIFont(name: "Inter-Medium", size: 11) ?? .ows_semiboldFont(withSize: 11)
    }
}
