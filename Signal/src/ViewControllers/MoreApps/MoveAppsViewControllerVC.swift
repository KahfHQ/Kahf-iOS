//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging
import SignalUI
import PanModal
import SnapKit

@objc
class MoveAppsViewControllerVC: UIViewController {

    lazy private var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "More Apps"
        view.font = UIFont.interBold24
        return view
    }()
    
    lazy private var stackView: UIStackView = {
       let view = UIStackView()
       view.axis = .horizontal
       view.backgroundColor = .white
       view.distribution = .fillEqually
       view.alignment = .center
       return view
    }()
    
    lazy private var customDragLine: UIView = {
       let view = UIView()
       view.backgroundColor = .black
       view.layer.cornerRadius = 1.5
       view.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(3)
       }
       return view
    }()
    
    lazy private var storyButton: CustomButtonView = {
      let view = CustomButtonView(title: "Story", image: Theme.iconImage(.kahfStoryIcon, renderingMode: .alwaysOriginal), action: {
          self.storyAction?()
      })
       view.snp.makeConstraints { make in
         make.width.equalTo(85)
         make.height.equalTo(81)
       }
       return view
    }()
    
    lazy private var mosqueNearbyButton: CustomButtonView = {
        let view = CustomButtonView(title: "Mosque Nearby", image: Theme.iconImage(.kahfMosqueNearbyIcon, renderingMode: .alwaysOriginal), action: {
            self.mosqueAction?()
        })
        view.snp.makeConstraints { make in
          make.width.equalTo(85)
          make.height.equalTo(81)
        }
        return view
    }()
    
    lazy private var eventsButton: CustomButtonView = {
        let view = CustomButtonView(title: "Events", image: Theme.iconImage(.kahfEventsIcon, renderingMode: .alwaysOriginal), action: {
            self.eventsAction?()
        })
        view.snp.makeConstraints { make in
          make.width.equalTo(85)
          make.height.equalTo(81)
        }
        return view
    }()
    
    lazy private var articlesButton: CustomButtonView = {
        let view = CustomButtonView(title: "Articles", image: Theme.iconImage(.kahfArticlesIcon, renderingMode: .alwaysOriginal), action: {
            self.articlesAction?()
        })
        view.snp.makeConstraints { make in
          make.width.equalTo(85)
          make.height.equalTo(81)
        }
        return view
    }()
    
    var storyAction: (() -> Void)?
    var mosqueAction: (() -> Void)?
    var eventsAction: (() -> Void)?
    var articlesAction: (() -> Void)?
    
    init(storyAction: (() -> Void)?, mosqueAction: (() -> Void)?, eventsAction: (() -> Void)?, articlesAction: (() -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.storyAction = storyAction
        self.mosqueAction = mosqueAction
        self.eventsAction = eventsAction
        self.articlesAction = articlesAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(titleLabel)
        self.view.addSubview(stackView)
        self.view.addSubview(customDragLine)
        stackView.addArrangedSubview(storyButton)
        stackView.addArrangedSubview(mosqueNearbyButton)
        stackView.addArrangedSubview(eventsButton)
        stackView.addArrangedSubview(articlesButton)
        makeConstraints()
    }
    
    func makeConstraints() {
        customDragLine.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
          make.top.equalToSuperview().offset(47)
          make.centerX.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
          make.top.equalTo(titleLabel.snp.bottom).offset(31)
          make.leading.trailing.equalToSuperview().inset(25)
          make.height.equalTo(81)
        }
    }
}

class CustomButtonView: UIView {

    // MARK: - Properties
    
    lazy private var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = UIFont.interMedium11
        view.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1)
        return view
    }()
    
    lazy private var buttonImage: UIImageView = {
       let view = UIImageView()
       return view
    }()
    
    var action: (() -> Void)?
    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(title: "Default Title", image: UIImage())
    }

    init(title: String, image: UIImage, action: (() -> Void)?) {
        super.init(frame: .zero)
        self.action = action
        commonInit(title: title, image: image)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        addGestureRecognizer(tapGesture)
    }

    private func commonInit(title: String, image: UIImage) {
        addSubview(titleLabel)
        addSubview(buttonImage)
        titleLabel.text = title
        buttonImage.image = image
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        buttonImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-5)
            make.width.height.equalTo(63)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Action

    @objc private func buttonTapped() {
        action?()
    }
}
extension MoveAppsViewControllerVC: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(227)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
    
    var showDragIndicator: Bool {
       return false
    }
}
