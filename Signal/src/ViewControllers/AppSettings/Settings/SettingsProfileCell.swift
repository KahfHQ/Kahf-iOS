//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import UIKit

class SettingsProfileCell: UITableViewCell {

    lazy private var hStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        return view
    }()
    
    lazy private var vStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 6
        return view
    }()
    
    lazy private var avatarImageView: ConversationAvatarView = {
       let view = ConversationAvatarView(sizeClass: .seventy, localUserDisplayMode: .asUser)
       return view
    }()
    
    lazy private var nameLabel: UILabel = {
       let view = UILabel()
       view.font = UIFont.interBold21
       view.textColor = UIColor.ows_gray01
       return view
    }()
    
    lazy private var subtitleLabel: UILabel = {
       let view = UILabel()
       view.font = UIFont.interRegular12
       view.textColor = UIColor.ows_gray03
       return view
    }()
    
    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        
        let snapshot = profileManagerImpl.localProfileSnapshot(shouldIncludeAvatar: false)

        if let localAddress = tsAccountManager.localAddress {
            avatarImageView.updateWithSneakyTransactionIfNecessary { config in
                config.dataSource = .address(localAddress)
            }
        }
        
        if let fullName = snapshot.givenName, !fullName.isEmpty {
            nameLabel.text = fullName
        } else {
            nameLabel.text = NSLocalizedString(
                "APP_SETTINGS_EDIT_PROFILE_NAME_PROMPT",
                comment: "Text prompting user to edit their profile name."
            )
            nameLabel.textColor = Theme.accentBlueColor
        }

        addSubtitleLabel(text: OWSUserProfile.bioForDisplay(bio: snapshot.bio, bioEmoji: snapshot.bioEmoji))
        
        if let phoneNumber = tsAccountManager.localNumber {
            addSubtitleLabel(
                text: PhoneNumber.bestEffortFormatPartialUserSpecifiedText(toLookLikeAPhoneNumber: phoneNumber),
                isLast: true
            )
        } else {
            owsFailDebug("Missing local number")
        }

        
        self.accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupConstraints() {
        hStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
        }
        let topSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
        vStackView.insertArrangedSubview(topSpacer, at: 0)
        vStackView.addArrangedSubview(bottomSpacer)
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
    }
    
    func addSubviews() {
        contentView.addSubview(hStackView)
        hStackView.addArrangedSubview(avatarImageView)
        hStackView.addArrangedSubview(vStackView)
        vStackView.addArrangedSubview(nameLabel)
        vStackView.addArrangedSubview(subtitleLabel)
    }
    
    func addSubtitleLabel(text: String?, isLast: Bool = false) {
        guard let text = text, !text.isEmpty else { return }
        subtitleLabel.text = text
    }
}
