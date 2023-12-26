//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import UIKit

class DateCell: UITableViewCell {
    
    lazy var dayNameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ows_gray01
        view.font = UIFont.interBold24
        view.text = "Today"
        return view
    }()
    
    lazy var dayFullInfoLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ows_kahf_gray2
        view.font = UIFont.interRegular12
        view.alpha = Date() > time ? 0.3 : 1.0
        view.text = "14 June 2023; 17:30"
        return view
    }()
    
    lazy var hourLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ows_kahf_gray2
        view.font = UIFont.interRegular12
        view.alpha = Date() > time ? 0.3 : 1.0
        view.text = "17:30"
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
        dayNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.bottom.equalToSuperview().offset(-6)
        }
        dayFullInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(dayNameLabel.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-9)
        }
        hourLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-9)
        }
    }
    
    func addSubviews() {
        contentView.addSubview(dayNameLabel)
        contentView.addSubview(dayFullInfoLabel)
        contentView.addSubview(hourLabel)
    }
}
