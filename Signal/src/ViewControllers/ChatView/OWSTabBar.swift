//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

import UIKit

@objc
public class OWSTabBar: UITabBar {

    lazy var selectedItemColor = UIColor(red: 0.24, green: 0.55, blue: 1, alpha: 1)
    
    
    private let topPadding: CGFloat = 20.0

    public override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadiusAndShadow()
        adjustTabBarItemLayout()
    }

    private func adjustTabBarItemLayout() {
        guard let tabBarItems = self.items else { return }
        let itemHeight = self.bounds.size.height
        let itemWidth = self.bounds.size.width / CGFloat(tabBarItems.count)
        for (index, item) in tabBarItems.enumerated() {
            let itemFrame = CGRect(x: CGFloat(index) * itemWidth, y: 0, width: itemWidth, height: 77)

            if let itemImageView = item.value(forKey: "view") as? UIView {
                itemImageView.frame = itemFrame
            }
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -(itemHeight - 61.0))
        }
    }
    
    // MARK: Subviews
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius =  10.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentsLayer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius =  10.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeDidChange),
                                               name: .ThemeDidChange,
                                               object: nil)

        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeDidChange),
                                               name: .ThemeDidChange,
                                               object: nil)

        setupView()
    }

    private func setupView() {
        addSubview(mainView)
        mainView.addSubview(contentsLayer)

        NSLayoutConstraint.activate([
            // Constrains your mainView to the ViewController's view
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Constrains your contentsLayer to the mainView
            contentsLayer.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            contentsLayer.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            contentsLayer.heightAnchor.constraint(equalTo: mainView.heightAnchor),
            contentsLayer.widthAnchor.constraint(equalTo: mainView.widthAnchor)
        ])
    }

    // MARK: Layout
    private func applyCornerRadiusAndShadow() {
        let cornerRadius: CGFloat = 10.0 // Set the corner radius to your desired value
        mainView.layer.cornerRadius = cornerRadius
        mainView.layer.masksToBounds = false // Allow the shadow to be visible

        // Apply corner radius to bottom corners only
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        mainView.setShadow(radius: 10.0, opacity: 1, offset: CGSize(width: 3, height: 10), color: UIColor.black)
    }

    // MARK: Theme

    var tabBarBackgroundColor: UIColor {
        Theme.navbarBackgroundColor
    }

    func applyTheme() {
        tintColor = selectedItemColor
    }

    @objc
    public func themeDidChange() {
        applyTheme()
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
          var size = super.sizeThatFits(size)
          size.height = 77
          return size
    }
}

