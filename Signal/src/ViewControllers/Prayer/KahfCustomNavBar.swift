//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import UIKit

class KahfCustomNavBar: UIView {

    lazy var logo: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = Theme.iconImage(.kahfHomeIcon, renderingMode: .alwaysOriginal)
        return view
    }()
    
    lazy private var avatarImageView: ConversationAvatarView = {
       let view = ConversationAvatarView(sizeClass: .thirtyTwo, localUserDisplayMode: .asUser)
       return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
        if let localAddress = tsAccountManager.localAddress {
             avatarImageView.updateWithSneakyTransactionIfNecessary { config in
                 config.dataSource = .address(localAddress)
             }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func makeConstraints() {
        logo.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.top.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalTo(logo.snp.centerY)
            make.trailing.equalToSuperview().offset(-30)
        }
    }
    
    func addSubviews() {
        self.addSubview(logo)
        self.addSubview(avatarImageView)
    }
}

