//
// Copyright 2023 Kahf Messenger, LLC
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
       view.isUserInteractionEnabled = true
       return view
    }()
    
    lazy var contextMenuButton: ContextMenuButton = {
        let contextButton = ContextMenuButton()
        contextButton.showsContextMenuAsPrimaryAction = true
        contextButton.frame = CGRectMake(0, 0, 32, 32);
        return contextButton
    }()
    
    lazy var button: UIView = {
        let wrapper = UIView.container()
        wrapper.addSubview(avatarImageView)
        wrapper.addSubview(contextMenuButton)
        contextMenuButton.autoPinEdgesToSuperviewEdges()
        wrapper.frame = CGRectMake(0, 0, 32, 32);
        return wrapper
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
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
            make.height.width.equalTo(32)
            make.centerY.equalTo(logo.snp.centerY)
        }
    }
    
    func addSubviews() {
        self.addSubview(logo)
        self.addSubview(button)
    }
}

