//
// Copyright 2023 Kahf Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

class MuteView: UIView {
    
    lazy var muteButtonView : UIButton = {
        var view = UIButton()
        view.frame = CGRect(x: 0, y: 0, width: 33, height: 33)
        view.backgroundColor = .ows_signalBlueDark.withAlphaComponent(0.3)
        view.layer.cornerRadius = 4
        view.setImage(muteImage, animated: false)
        view.snp.makeConstraints { make in make.width.height.equalTo(33) }
        view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var muteImage : UIImage = Theme.iconImage(.kahfAlertNotif, renderingMode: .alwaysOriginal).withTintColor(.white)
    lazy var unmuteImage : UIImage = Theme.iconImage(.kahfAlertDisabled, renderingMode: .alwaysOriginal).withTintColor(.ows_signalBlue)
    
    lazy var muteLabel: UILabel = {
       let view = UILabel()
       view.text = "Mute"
       view.textColor = .white
       view.font = UIFont.interRegular12
       return view
    }()
    
    var isMuted = false
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        addSubviews()
        makeConstraints()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        self.addSubview(muteButtonView)
        self.addSubview(muteLabel)
    }
    
    func makeConstraints() {
        muteButtonView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(33)
        }
        muteLabel.snp.makeConstraints { make in
            make.centerY.equalTo(muteButtonView.snp.centerY)
            make.leading.equalTo(muteButtonView.snp.trailing).offset(7)
        }
    }
    
    @objc func buttonTapped() {
        isMuted.toggle()
        if isMuted {
            muteLabel.text = "Unmute"
            muteButtonView.backgroundColor = .white
            muteButtonView.setImage(unmuteImage, animated: true)
        }
        else {
            muteLabel.text = "Mute"
            muteButtonView.backgroundColor = .ows_signalBlueDark.withAlphaComponent(0.3)
            muteButtonView.setImage(muteImage, animated: true)
        }
    }
}
