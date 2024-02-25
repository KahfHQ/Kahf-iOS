//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalCoreKit
import SignalServiceKit
import SignalMessaging
import UIKit
import SnapKit
import SignalUI

@objc
public extension ChatListViewController {
    
    func addStartToChatIcon() {
        let startToChatButton = UIButton(type: .custom)
        startToChatButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        startToChatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        startToChatButton.setImage(UIImage(named: "startToChatButtonIcon"), for: .normal)
        startToChatButton.addTarget(self, action: #selector(showNewConversationView), for: .touchUpInside)
        self.view.addSubview(startToChatButton)
        startToChatButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-97)
            make.width.height.equalTo(48)
            make.trailing.equalTo(-30)
        }
    }
    
    func addNavBarCameraButton() {
        let cameraButton = UIButton(type: .custom)
        cameraButton.setImage(Theme.iconImage(ThemeIcon.cameraButton), for: .normal)
        cameraButton.addTarget(self, action: #selector(showCameraView), for: .touchUpInside)
        cameraButton.accessibilityLabel = NSLocalizedString("CAMERA_BUTTON_LABEL", comment: "Accessibility label for camera button.")
        cameraButton.accessibilityHint = NSLocalizedString("CAMERA_BUTTON_HINT", comment: "Accessibility hint describing what you can do with the camera button")
        cameraButton.frame = CGRect(x: 0, y: 0, width: 22, height: 20) // Adjust the frame as needed
        self.customRightView.addSubview(cameraButton)
    }
    
    func addNavBarSettingsButton() {
        let settingsButton = createSettingsBarButtonItem()
        settingsButton.accessibilityLabel = CommonStrings.openSettingsButton;
        settingsButton.frame = CGRectMake(42, 0, 22, 20);
        self.customRightView.addSubview(settingsButton)
    }
    
    func addNavBarLogo() {
        customLeftView = UIView(frame: CGRect(x: 30, y: 0, width: 100, height: 40))
        customLeftView.backgroundColor = UIColor.white
        customRightView = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width - 92, y: 16, width: 92, height: 22))
        customRightView.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: customLeftView.bounds)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = Theme.iconImage(.kahfHomeIcon, renderingMode: .alwaysOriginal)
        customLeftView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(customLeftView.snp.top)
            make.bottom.equalTo(customLeftView.snp.bottom)
            make.leading.equalTo(customLeftView.snp.leading)
            make.trailing.equalTo(customLeftView.snp.trailing)
        }
        navigationController?.navigationBar.addSubview(customLeftView)
        navigationController?.navigationBar.addSubview(customRightView)
    }
}
