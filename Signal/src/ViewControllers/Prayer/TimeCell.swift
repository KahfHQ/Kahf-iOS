//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import UIKit

class TimeCell: UITableViewCell {
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ows_gray01
        view.font = UIFont.interMedium16
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ows_kahf_gray2
        view.font = UIFont.interMedium12
        return view
    }()
    
    lazy var alarmButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(alarmButtonTapped), for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.width.equalTo(18)
            make.height.equalTo(18)
        }
        return button
    }()
    
    var alarmButtonAction : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    init(reuseIdentifier: String?, name: String, time: Date, isAlarmSet: Bool) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        self.accessoryType = .none
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.nameLabel.text = name
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        self.timeLabel.text = "\(formatter.string(from: time))"
        if Date() > time {
            alarmButton.setImage(Theme.iconImage(isAlarmSet ? .kahfAlertDisabled :.kahfAlert, renderingMode: .alwaysOriginal).withTintColor(.ows_gray01), for: .normal)
            bgView.alpha = 0.3
            bgView.backgroundColor = .ows_gray06
            bgView.isUserInteractionEnabled = false
        }
        else {
            alarmButton.setImage(Theme.iconImage(isAlarmSet ? .kahfAlertDisabled :.kahfAlert, renderingMode: .alwaysOriginal), for: .normal)
            bgView.alpha = 1.0
            bgView.backgroundColor = .white
            bgView.isUserInteractionEnabled = true
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        bgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
        }
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(alarmButton.snp.leading).offset(-26)
        }
        alarmButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func addSubviews() {
        contentView.addSubview(bgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(timeLabel)
        bgView.addSubview(alarmButton)
    }
    
    @objc func alarmButtonTapped() {
        alarmButtonAction?()
    }
}

