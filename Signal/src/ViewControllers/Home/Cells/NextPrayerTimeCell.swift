//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import Adhan

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
        view.addSubview(bottomShadowView)
        view.addSubview(allPrayerTime)
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
    
    lazy private var bottomShadowView: UIImageView = {
        let view = UIImageView()
        view.image = Theme.iconImage(.kahfNextPrayerBottomShadow, renderingMode: .alwaysOriginal)
        return view
    }()
    
    lazy private var allPrayerTime: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 21
        view.backgroundColor = .white
        view.snp.makeConstraints { make in
            make.height.equalTo(43)
            make.width.equalTo(177)
        }
        let titleLabel = UILabel()
        titleLabel.font = UIFont.interMedium14
        titleLabel.textColor = UIColor.ows_signalBlue
        titleLabel.text = "All Prayer Time"
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(13)
        }
        let arrowImageView = UIImageView(image: Theme.iconImage(.kahfRightArrow, renderingMode: .alwaysOriginal))
        arrowImageView.contentMode = .scaleAspectFit
        view.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-25)
            make.leading.equalTo(titleLabel.snp.trailing).offset(11)
            make.centerY.equalToSuperview()
            make.width.equalTo(16)
            make.height.equalTo(12)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(allPrayerTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    lazy private var muteView: MuteView = {
       let view = MuteView()
       view.muteButtonView.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
       if let alarm = self.alarms.getAlarm(ByUUIDStr: "alarm_set_at_\(date.timeIntervalSince1970)") {
            if alarm.mediaLabel.isEmpty {
                view.isMuted = false
            }
            else {
                view.isMuted = false
            }
        } else {
            view.isMuted = true
       }
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
        view.font = UIFont.interBold30
        view.text = "6:39"
        view.adjustsFontSizeToFitWidth = true
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
    
    let prayerManager = PrayerManager.shared
    var buttonAction: (() -> Void)?
    var date: Date
    var alarms = Store.shared.alarms
    var tabBar: HomeTabBarController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    init(reuseIdentifier: String?, next: Prayer, nextPrayer: Date) {
        self.date = nextPrayer
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .orange
        addSubviews()
        setupConstraints()
        self.accessoryType = .none
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.prayerNameLabel.text = prayerManager.getRawValue(prayer: next)
        self.timeLeftLabel.text = prayerManager.calculateLeftTimeNextPrayerTime(next: next, date: nextPrayer)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.current
        hourLabel.text = dateFormatter.string(from: nextPrayer)
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
            make.width.equalTo(82)
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
        bottomShadowView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(mainBgImageView.snp.bottom)
            make.height.equalTo(10)
        }
        allPrayerTime.snp.makeConstraints { make in
            make.top.equalTo(mainBgImageView.snp.bottom).offset(-21)
            make.centerX.equalToSuperview()
        }
    }
    
    func addSubviews() {
        contentView.addSubview(fullBackgroundView)
    }
    
    @objc func buttonTapped() {
        if let alarm = self.alarms.getAlarm(ByUUIDStr: "alarm_set_at_\(date.timeIntervalSince1970)") {
            self.alarms.remove(alarm.id)
         } else {
             let alarm = Alarm(id: "alarm_set_at_\(date.timeIntervalSince1970)", date: date, enabled: true, snoozeEnabled: true, repeatWeekdays: [], mediaID: "bell", mediaLabel: "", label: self.prayerNameLabel.text ?? "")
             self.alarms.add(alarm)
        }
        muteView.isMuted.toggle()
    }
    
    @objc func allPrayerTapped() {
        tabBar?.selectedTab = .prayer
    }
}
