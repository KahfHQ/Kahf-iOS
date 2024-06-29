//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

class NewStoriesCell: UICollectionViewCell {

    // Example label to display item text
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.interRegular14
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        return view
    }()

    lazy var profileImageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 17
        view.snp.makeConstraints { make in
            make.height.width.equalTo(34)
        }
        view.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.center.equalToSuperview()
        }
        return view
    }()


    lazy var avatarView: ConversationAvatarView =  {
        let avatarView = ConversationAvatarView(
            sizeClass: .thirtyTwo,
            localUserDisplayMode: .asUser,
            useAutolayout: false)
        return avatarView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        layer.cornerRadius = 10

        addSubview(containerView)
        addSubview(profileImageContainer)
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-39)
        }
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-18)
        }
        profileImageContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.width.equalTo(34)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with story: StoryViewModel) {
        titleLabel.text = story.latestMessageName
        let latestThumbnailView = StoryThumbnailView(attachment: story.latestMessageAttachment)
        containerView.addSubview(latestThumbnailView)

        latestThumbnailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        SDSDatabaseStorage.shared.read { transaction in
            avatarView.update(transaction) { config in
                config.dataSource = story.latestMessageAvatarDataSource
            }
        }
    }

    func configure(with story: MyStoryViewModel) {
        titleLabel.text = "My Story"

        if let latestThumbnailView = story.latestMessageAttachment {
            let attachment = StoryThumbnailView(attachment: latestThumbnailView)
            containerView.addSubview(attachment)

            attachment.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        avatarView.updateWithSneakyTransactionIfNecessary { config in
            config.dataSource = .address(Self.tsAccountManager.localAddress!)
        }
    }
}
