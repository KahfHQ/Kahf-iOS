//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import UIKit

class RunningPrayerCell: UITableViewCell {

    lazy var backgroundImage: UIImageView = {
       let imageView = UIImageView(image: Theme.iconImage(.kahfRunningPrayer, renderingMode: .alwaysOriginal))
       imageView.layer.masksToBounds = true
       imageView.layer.cornerRadius = 10
       return imageView
    }()
    
    lazy var smallTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "Running Prayer"
        view.textColor = .white
        view.font = UIFont.interRegular14
        return view
    }()
    
    lazy var bigTitleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.interBold36
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.interRegular11
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    init(reuseIdentifier: String?, current: String, next: String, coundown: Date) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        self.accessoryType = .none
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.bigTitleLabel.text = current
        self.contentLabel.text = next
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date(), to: coundown)
        if let hours = components.hour, let minutes = components.minute {
            var labelText = ""
                
            if hours > 0 {
                labelText += "\(hours) hours"
            }
            
            if minutes > 0 {
                if labelText.count > 0 {
                    labelText += " "
                }
                labelText += "\(minutes) minutes"
            }

            if labelText.count > 0 {
                labelText += " until \(next)"
                self.contentLabel.text = labelText
            } else {
                self.contentLabel.text = "Event is happening now or in the past."
            }
        } else {
            print("Unable to calculate duration.")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        backgroundImage.snp.makeConstraints { make in
            make.height.equalTo(146)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        smallTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(17)
            make.leading.equalToSuperview().offset(55)
            make.top.equalToSuperview().offset(30)
        }
        bigTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(55)
            make.top.equalTo(smallTitleLabel.snp.bottom).offset(2)
        }
        contentLabel.snp.makeConstraints { make in
            make.height.equalTo(13)
            make.leading.equalToSuperview().offset(55)
            make.top.equalTo(bigTitleLabel.snp.bottom).offset(3)
        }
    }
    
    func addSubviews() {
        addSubview(backgroundImage)
        addSubview(smallTitleLabel)
        addSubview(bigTitleLabel)
        addSubview(contentLabel)
    }

}
