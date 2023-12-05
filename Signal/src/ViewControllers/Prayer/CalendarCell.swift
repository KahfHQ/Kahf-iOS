//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import UIKit

class CalendarCell: UITableViewCell {
    
    lazy var bgView: UIView = {
       let view = UIView()
        return view
    }()
    
    lazy var smallTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "Dhaka  |  15 June 2023"
        view.textColor = .blue
        view.font = UIFont.interSemiBold12
        return view
    }()
    
    lazy var bigTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "Today"
        view.textColor = .black
        view.font = UIFont.interBold24
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.text = "Dgy Al-Ql’dah 30, 1444 AH"
        view.textColor = .ows_gray03
        view.font = UIFont.interRegular12
        return view
    }()
    
    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setImage(Theme.iconImage(.kahfCalendarLeft, renderingMode: .alwaysOriginal), for: .normal)
        button.snp.makeConstraints { make in
            make.width.equalTo(11)
            make.height.equalTo(18)
        }
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setImage(Theme.iconImage(.kahfCalendarRight, renderingMode: .alwaysOriginal), for: .normal)
        button.snp.makeConstraints { make in
            make.width.equalTo(11)
            make.height.equalTo(18)
        }
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bigTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(29)
            make.centerX.equalToSuperview()
        }
        smallTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bigTitleLabel.snp.bottom).offset(7)
            make.height.equalTo(15)
            make.centerX.equalToSuperview()
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(smallTitleLabel.snp.bottom).offset(5)
            make.height.equalTo(15)
            make.centerX.equalToSuperview()
        }
        leftButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(55)
        }
        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-36)
            make.top.equalToSuperview().offset(55)
        }
    }
    
    func addSubviews() {
        addSubview(bgView)
        bgView.addSubview(smallTitleLabel)
        bgView.addSubview(bigTitleLabel)
        bgView.addSubview(contentLabel)
        bgView.addSubview(leftButton)
        bgView.addSubview(rightButton)
    }

}

