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
    
    @objc(interBold21)
    class var interBold21: UIFont {
        UIFont(name: "Inter-Bold", size: 21) ?? .boldSystemFont(ofSize: 21)
    }
    
    @objc(interBold24)
    class var interBold24: UIFont {
        UIFont(name: "Inter-Bold", size: 24) ?? .boldSystemFont(ofSize: 24)
    }
    
    @objc(interBold36)
    class var interBold36: UIFont {
        UIFont(name: "Inter-Bold", size: 36) ?? .boldSystemFont(ofSize: 36)
    }
    
    @objc(interSemiBold12)
    class var interSemiBold12: UIFont {
        return UIFont(name: "Inter-SemiBold", size: 12) ?? .ows_semiboldFont(withSize: 12)
    }
    
    @objc(interSemiBold16)
    class var interSemiBold16: UIFont {
        return UIFont(name: "Inter-SemiBold", size: 16) ?? .ows_semiboldFont(withSize: 16)
    }

    @objc(interRegular11)
    class var interRegular11: UIFont {
        return UIFont(name: "Inter-Regular", size: 11) ?? .ows_regularFont(withSize: 11)
    }
    
    @objc(interRegular12)
    class var interRegular12: UIFont {
        return UIFont(name: "Inter-Regular", size: 12) ?? .ows_regularFont(withSize: 12)
    }
    
    @objc(interRegular14)
    class var interRegular14: UIFont {
        return UIFont(name: "Inter-Regular", size: 14) ?? .ows_regularFont(withSize: 14)
    }
    
    @objc(interRegular16)
    class var interRegular16: UIFont {
        return UIFont(name: "Inter-Regular", size: 16) ?? .ows_regularFont(withSize: 16)
    }
    
    @objc(interMedium11)
    class var interMedium11: UIFont {
        return UIFont(name: "Inter-Medium", size: 11) ?? .ows_semiboldFont(withSize: 11)
    }
    
    @objc(interMedium12)
    class var interMedium12: UIFont {
        return UIFont(name: "Inter-Medium", size: 12) ?? .ows_semiboldFont(withSize: 12)
    }
    
    @objc(interMedium14)
    class var interMedium14: UIFont {
        return UIFont(name: "Inter-Medium", size: 14) ?? .ows_semiboldFont(withSize: 14)
    }
    
    @objc(interMedium16)
    class var interMedium16: UIFont {
        return UIFont(name: "Inter-Medium", size: 16) ?? .ows_semiboldFont(withSize: 16)
    }
}
