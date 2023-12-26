//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

class NextPrayerTimeCell: UITableViewCell {
    
    lazy var fullBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(mainBackgroundView)
        return view
    }()
    
    lazy var mainBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.addSubview(mainBgImageView)
        return view
    }()
    
    lazy var mainBgImageView: UIImageView = {
       let view = UIImageView()
       view.isUserInteractionEnabled = true
       view.image = Theme.iconImage(.kahfNextPrayerTimeBg, renderingMode: .alwaysOriginal)
       view.addSubview(muteView)
       view.addSubview(nextPrayerLabel)
       view.addSubview(hourLabel)
       view.addSubview(prayerNameLabel)
       view.addSubview(timeLeftLabel)
       return view
    }()
    
    lazy private var muteView: MuteView = {
       let view = MuteView()
       
       return view
    }()
    
    
    lazy var nextPrayerLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.interRegular14
        view.text = "Next Prayer Time"
        return view
    }()
    
    lazy var hourLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.interBold36
        view.text = "6:39"
        return view
    }()
    
    lazy var prayerNameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.interBold14
        view.text = "Magrib"
        return view
    }()
    
    lazy var timeLeftLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.interRegular11
        view.text = "20 Minutes Left"
        return view
    }()
    
    var time: Date
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    init(reuseIdentifier: String?, time: Date) {
        self.time = time
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .orange
        addSubviews()
        setupConstraints()
        self.accessoryType = .none
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        fullBackgroundView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        mainBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(21)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-22)
        }
        mainBgImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-21)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        muteView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(35)
            make.top.equalToSuperview().offset(43)
            make.height.equalTo(33)
            make.width.equalTo(85)
        }
        nextPrayerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(35)
            make.top.equalTo(muteView.snp.bottom).offset(13)
        }
        hourLabel.snp.makeConstraints { make in
            make.top.equalTo(nextPrayerLabel.snp.bottom).offset(8)
            make.height.equalTo(42)
            make.leading.equalToSuperview().offset(35)
        }
        prayerNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(hourLabel.snp.trailing).offset(13)
            make.centerY.equalTo(hourLabel.snp.centerY)
        }
        timeLeftLabel.snp.makeConstraints { make in
            make.top.equalTo(hourLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(35)
        }
    }
    
    func addSubviews() {
        contentView.addSubview(fullBackgroundView)
    }
}
