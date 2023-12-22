//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import UIKit
import SignalServiceKit
import SignalUI
import PanModal

class HomeTabBarController: UITabBarController {
    lazy var selectedItemColor = UIColor(red: 0.24, green: 0.55, blue: 1, alpha: 1)
    var customTabBarView = UIView(frame: .zero)
    enum Tabs: Int {
        case home = 0
        case stories = 1
        case chatList = 2
        case prayer = 3
        case settings = 4
    }
    lazy var homeNavController = HomeViewController.inModalNavigationController()
    lazy var homeTabBarItem = UITabBarItem(title: "Home",
        image: UIImage(named: "tabbar-home"),
        selectedImage: UIImage(named: "tabbar-home")!)
    lazy var prayerNavController = PrayerVC.inModalNavigationController()
    lazy var prayerTabBarItem = UITabBarItem(title: "Prayer",
        image: UIImage(named: "tabbar-prayer"),
        selectedImage: UIImage(named: "tabbar-prayer")!)
    lazy var settingsNavController = AppSettingsViewController.inModalNavigationController()
    lazy var settingsTabBarItem = UITabBarItem(title: NSLocalizedString("SETTINGS_NAV_BAR_TITLE",
        comment: "Title for settings activity"),
        image: UIImage(named: "tabbar-settings"),
        selectedImage: UIImage(named: "tabbar-settings")!)
    lazy var chatListViewController = ChatListViewController()
    lazy var chatListNavController = OWSNavigationController(rootViewController: chatListViewController)
    lazy var chatListTabBarItem = UITabBarItem(
        title: NSLocalizedString("CHAT_LIST_TITLE_INBOX",
        comment: "Title for the chat list's default mode."),
        image: UIImage(named: "tabbar-chat"),
        selectedImage: UIImage(named: "tabbar-chat")!
    )
    lazy var storiesViewController = StoriesViewController()
    lazy var storiesNavController = OWSNavigationController(rootViewController: storiesViewController)
    lazy var wpViewController = WpTelegramVC()
    lazy var wpNavController = OWSNavigationController(rootViewController: wpViewController)
    
    lazy var moreAppsVC = MoveAppsViewControllerVC(storyAction: {}, mosqueAction: {}, eventsAction: {}, articlesAction: {})
    
    
    lazy var storiesTabBarItem = UITabBarItem(
        title: NSLocalizedString("STORIES_TITLE",
        comment: "Title for the stories view."),
        image: UIImage(named: "tabbar-story"),
        selectedImage: UIImage(named: "tabbar-story")
    )
    
    lazy var wpTabBarItem = UITabBarItem(
        title: "Safe Chat",
        image: UIImage(named: "tabbar-wp"),
        selectedImage: UIImage(named: "tabbar-wp")
    )
    
    var selectedTab: Tabs {
        get { Tabs(rawValue: selectedIndex) ?? .chatList }
        set { selectedIndex = newValue.rawValue }
    }

    var owsTabBar: OWSTabBar? {
        return tabBar as? OWSTabBar
    }

    private lazy var storyBadgeCountManager = StoryBadgeCountManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Use our custom tab bar.
        setValue(OWSTabBar(), forKey: "tabBar")

        delegate = self

        // Don't render the tab bar at all if stories isn't enabled.
        guard RemoteConfig.stories else {
            viewControllers = [chatListNavController]
            self.setTabBarHidden(true, animated: false)
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(storiesEnabledStateDidChange), name: .storiesEnabledStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .ThemeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: .OWSApplicationWillEnterForeground, object: nil)
        applyTheme()

        databaseStorage.appendDatabaseChangeDelegate(self)

        viewControllers = [homeNavController,wpNavController,chatListNavController, prayerNavController, settingsNavController]
        homeNavController.tabBarItem = homeTabBarItem
        chatListNavController.tabBarItem = chatListTabBarItem
        wpNavController.tabBarItem = wpTabBarItem
        prayerNavController.tabBarItem = prayerTabBarItem
        settingsNavController.tabBarItem = settingsTabBarItem
        
        updateChatListBadge()
        storyBadgeCountManager.beginObserving(observer: self)

        // We read directly from the database here, as the cache may not have been warmed by the time
        // this view is loaded (since it's the very first thing to load). Otherwise, there can be a
        // small window where the tab bar is in the wrong state at app launch.
        let shouldHideTabBar = !databaseStorage.read { StoryManager.areStoriesEnabled(transaction: $0) }
        setTabBarHidden(shouldHideTabBar, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UITabBarAppearance()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: selectedItemColor, .font: UIFont.interMedium11]
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -15)
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -15)
        self.tabBar.standardAppearance = appearance
    }

    @objc
    func didEnterForeground() {
        if selectedTab == .stories {
            storyBadgeCountManager.markAllStoriesRead()
        }
    }

    @objc
    func applyTheme() {
        tabBar.tintColor = UIColor(red: 0.24, green: 0.55, blue: 1.00, alpha: 1.00)
    }

    @objc
    func storiesEnabledStateDidChange() {
        if StoryManager.areStoriesEnabled {
            setTabBarHidden(false, animated: false)
        } else {
            if selectedTab == .stories {
                wpNavController.popToRootViewController(animated: false)
            }
            selectedTab = .chatList
            setTabBarHidden(true, animated: false)
        }
    }

    func updateChatListBadge() {
        guard RemoteConfig.stories else { return }
        let unreadMessageCount = databaseStorage.read { transaction in
            InteractionFinder.unreadCountInAllThreads(transaction: transaction.unwrapGrdbRead)
        }
        chatListTabBarItem.badgeValue = unreadMessageCount > 0 ? "\(unreadMessageCount)" : nil
    }

    // MARK: - Hiding the tab bar

    private var isTabBarHidden: Bool = false

    /// Hides or displays the tab bar, resizing `selectedViewController` to fill the space remaining.
    public func setTabBarHidden(
        _ hidden: Bool,
        animated: Bool = true,
        duration: TimeInterval = 0.15,
        completion: ((Bool) -> Void)? = nil
    ) {
        defer {
            isTabBarHidden = hidden
        }

        guard isTabBarHidden != hidden else {
            tabBar.isHidden = hidden
            owsTabBar?.applyTheme()
            completion?(true)
            return
        }

        let oldFrame = self.tabBar.frame
        let containerHeight = tabBar.superview?.bounds.height ?? 0
        let newMinY = hidden ? containerHeight : containerHeight - oldFrame.height
        let additionalSafeArea = hidden
            ? (-oldFrame.height + view.safeAreaInsets.bottom)
            : (oldFrame.height - view.safeAreaInsets.bottom)

        let animations = {
            self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: newMinY - oldFrame.y)
            if let vc = self.selectedViewController {
                var additionalSafeAreaInsets = vc.additionalSafeAreaInsets
                additionalSafeAreaInsets.bottom += additionalSafeArea
                vc.additionalSafeAreaInsets = additionalSafeAreaInsets
            }

            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }

        if animated {
            // Unhide for animations.
            self.tabBar.isHidden = false
            let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
                animations()
            }
            animator.addCompletion({
                self.tabBar.isHidden = hidden
                self.owsTabBar?.applyTheme()
                completion?($0 == .end)
            })
            animator.startAnimation()
        } else {
            animations()
            self.tabBar.isHidden = hidden
            owsTabBar?.applyTheme()
            completion?(true)
        }
    }
}

extension HomeTabBarController: DatabaseChangeDelegate {
    func databaseChangesDidUpdate(databaseChanges: DatabaseChanges) {
        if databaseChanges.didUpdateInteractions || databaseChanges.didUpdateModel(collection: String(describing: ThreadAssociatedData.self)) {
            updateChatListBadge()
        }
    }

    func databaseChangesDidUpdateExternally() {
        updateChatListBadge()
    }

    func databaseChangesDidReset() {
        updateChatListBadge()
    }
}

extension HomeTabBarController: StoryBadgeCountObserver {

    public var isStoriesTabActive: Bool {
        return selectedTab == .stories && CurrentAppContext().isAppForegroundAndActive()
    }

    public func didUpdateStoryBadge(_ badge: String?) {
        storiesTabBarItem.badgeValue = badge
        var views: [UIView] = [tabBar]
        var badgeViews = [UIView]()
        while let view = views.popLast() {
            if NSStringFromClass(view.classForCoder) == "_UIBadgeView" {
                badgeViews.append(view)
            }
            views = view.subviews + views
        }
        let sortedBadgeViews = badgeViews.sorted { lhs, rhs in
            let lhsX = view.convert(CGPoint.zero, from: lhs).x
            let rhsX = view.convert(CGPoint.zero, from: rhs).x
            if CurrentAppContext().isRTL {
                return lhsX > rhsX
            } else {
                return lhsX < rhsX
            }
        }
        let badgeView = sortedBadgeViews[safe: Tabs.stories.rawValue]
        badgeView?.layer.transform = CATransform3DIdentity
        let xOffset: CGFloat = CurrentAppContext().isRTL ? 0 : -5
        badgeView?.layer.transform = CATransform3DMakeTranslation(xOffset, 1, 1)
    }
}

extension HomeTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // If we re-select the active tab, scroll to the top.
        if selectedViewController == viewController {
            let tableView: UITableView
            switch selectedTab {
            case .chatList:
                tableView = chatListViewController.tableView
            case .stories:
                tableView = storiesViewController.tableView
            default: return true
            }

            tableView.setContentOffset(CGPoint(x: 0, y: -tableView.safeAreaInsets.top), animated: true)
        }
        
        if viewControllers?[4] == viewController {
            moreAppsVC.storyAction = { self.showStories() }
            moreAppsVC.mosqueAction = { print("mosqueAction") }
            moreAppsVC.eventsAction = { print("eventsAction") }
            moreAppsVC.articlesAction = { print("articlesAction") }
            presentPanModal(moreAppsVC)
            return false
        }
        
        return true
    }
    
    func showStories() {
        if let selectedViewController = self.viewControllers?[selectedTab.rawValue] {
            if let navigationController = selectedViewController as? UINavigationController {
                self.tabBar.setIsHidden(true, animated: true)
                self.moreAppsVC.dismiss(animated: true)
                let vc = StoriesViewController()
                DispatchQueue.main.async {
                    navigationController.pushViewController(vc, animated: true)
                }
            }
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if isStoriesTabActive {
            storyBadgeCountManager.markAllStoriesRead()
        }
    }
}
