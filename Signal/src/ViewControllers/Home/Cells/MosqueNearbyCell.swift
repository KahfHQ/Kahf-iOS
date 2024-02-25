//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import CoreLocation
import MapKit

class MosqueNearbyCell: UITableViewCell {
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var mosqueNearbyTitleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ows_gray01
        view.font = UIFont.interRegular14
        view.text = "Mosque Nearby"
        return view
    }()
    
    lazy var mosqueNearbyLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ows_signalBlue
        view.font = UIFont.interBold24
        view.text = "Masjid al-Fatah"
        return view
    }()
    
    lazy var locationLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ows_gray03
        view.font = UIFont.interRegular14
        view.text = "0.25 KM from your location"
        return view
    }()
    
    lazy var directionImage: UIButton = {
       let view = UIButton()
       view.setImage(Theme.iconImage(.kahfMosqueDirection, renderingMode: .alwaysOriginal), animated: true)
       view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
       return view
    }()
    
    var mosqueNearbyManager = MosqueNearbyManager.shared
    var mosque: Mosque
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    init(reuseIdentifier: String?, mosque: Mosque) {
        self.mosque = mosque
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        bgView.setShadow(radius: 50, opacity: 0.05, offset: CGSize(width: 0, height: 4), color: .ows_black)
        self.accessoryType = .none
        self.selectionStyle = .none
        self.backgroundColor = .clear
        mosqueNearbyLabel.text = mosque.name
        locationLabel.text = mosque.distanceString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        bgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
        }
        mosqueNearbyTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(27)
        }
        mosqueNearbyLabel.snp.makeConstraints { make in
            make.top.equalTo(mosqueNearbyTitleLabel.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(27)
        }
        locationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(27)
            make.top.equalTo(mosqueNearbyLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview().offset(-31)
        }
        directionImage.snp.makeConstraints { make in
            make.height.width.equalTo(29)
            make.trailing.equalToSuperview().offset(-35)
            make.centerY.equalToSuperview()
        }
    }
    
    func addSubviews() {
        contentView.addSubview(bgView)
        bgView.addSubview(mosqueNearbyTitleLabel)
        bgView.addSubview(mosqueNearbyLabel)
        bgView.addSubview(locationLabel)
        bgView.addSubview(directionImage)
    }
    
    @objc func buttonTapped() {
        guard let coordinate = mosque.mosqueCoordinate else { return }
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = mosque.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
