//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import UIKit

class SettingsCell: UITableViewCell {

    lazy var icon: UIImageView = {
        let view = UIImageView()
        view.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        return view
    }()
    
    lazy var nameLabel: UILabel = {
       let view = UILabel()
       view.font = UIFont.interMedium14
       view.textColor = UIColor.ows_gray01
       return view
    }()
    
    init(title: String, iconImage: UIImage, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        
        self.icon.image = iconImage
        self.nameLabel.text = NSLocalizedString(title, comment: "")
        self.accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupConstraints() {
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.top.bottom.equalToSuperview().inset(17)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalTo(icon.snp.trailing).offset(20)
        }
    }
    
    func addSubviews() {
        addSubview(icon)
        addSubview(nameLabel)
    }
}
