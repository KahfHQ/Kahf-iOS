//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SnapKit
import UIKit
import WebRTC
import SignalServiceKit
import SignalMessaging
import SignalRingRTC

class NewStoriesViewController: OWSViewController,StoryListDataSourceDelegate {
    var collectionViewIfLoaded: UICollectionView?

    func collectionViewDidUpdate() {
        self.collectionView.reloadData()
    }

    var showTabBar: (() -> Void)?
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NewStoriesCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var dataSource = StoryListDataSource(delegate: self)
    private lazy var contextMenuGenerator = StoryContextMenuGenerator(presentingController: self, delegate: self)

    override init() {
        super.init()
        // Want to start loading right away to prevent cases where things aren't loaded
        // when you tab over into the stories list.
        dataSource.reloadStories()
        dataSource.beginObservingDatabase()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(containerView)
        containerView.addSubview(collectionView)

        addStartToChatIcon()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(19)

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        showTabBar?()
    }

    func addStartToChatIcon() {
        let startToChatButton = UIButton(type: .custom)
        startToChatButton.setImage(UIImage(named: "startToChatButtonIcon"), for: .normal)
        startToChatButton.addTarget(self, action: #selector(showCameraView), for: .touchUpInside)
        self.view.addSubview(startToChatButton)
        startToChatButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-97)
            make.width.height.equalTo(48)
            make.trailing.equalTo(-30)
        }
    }

    @objc
    func showCameraView() {
        AssertIsOnMainThread()

        ows_askForCameraPermissions { cameraGranted in
            guard cameraGranted else {
                return Logger.warn("camera permission denied.")
            }
            self.ows_askForMicrophonePermissions { micGranted in
                if !micGranted {
                    // We can still continue without mic permissions, but any captured video will
                    // be silent.
                    Logger.warn("proceeding, though mic permission denied.")
                }

                let modal = CameraFirstCaptureNavigationController.cameraFirstModal(storiesOnly: true, delegate: self)
                self.presentFullScreen(modal, animated: true)
            }
        }
    }
}

extension NewStoriesViewController: StoryPageViewControllerDataSource {
    func storyPageViewControllerAvailableContexts(
        _ storyPageViewController: StoryPageViewController,
        hiddenStoryFilter: Bool?
    ) -> [StoryContext] {
        if hiddenStoryFilter == true {
            return dataSource.threadSafeHiddenStoryContexts
        } else if hiddenStoryFilter == false {
            return dataSource.threadSafeVisibleStoryContexts
        } else {
            return dataSource.threadSafeStoryContexts
        }
    }
}

extension NewStoriesViewController: StoryContextMenuDelegate {

    func storyContextMenuDidUpdateHiddenState(_ message: StoryMessage, isHidden: Bool) -> Bool {
        if isHidden {
            // Uncollapse so we can scroll to the section.
            dataSource.isHiddenStoriesSectionCollapsed = false
        }
        //self.scrollTarget = .context(message.context, section: isHidden ? .hiddenStories : .visibleStories)
        // Don't show a toast, we have the scroll action.
        return false
    }
}


extension NewStoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let myStory = dataSource.myStory {
            return 1 + dataSource.allStories.count
        } else {
            return dataSource.allStories.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let myStory = dataSource.myStory {
            if indexPath.row == 0  {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NewStoriesCell
                cell.configure(with: myStory)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NewStoriesCell
                cell.configure(with: dataSource.allStories[indexPath.row - 1])
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NewStoriesCell
            cell.configure(with: dataSource.allStories[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 20
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 234)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }
}

extension NewStoriesViewController: CameraFirstCaptureDelegate {
    func cameraFirstCaptureSendFlowDidComplete(_ cameraFirstCaptureSendFlow: CameraFirstCaptureSendFlow) {
        dismiss(animated: true)
    }

    func cameraFirstCaptureSendFlowDidCancel(_ cameraFirstCaptureSendFlow: CameraFirstCaptureSendFlow) {
        dismiss(animated: true)
    }
}
