//
//  MeetingViewModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

final class MeetingViewModel: NSObject {

    private(set) var hmsInterface: HMSInterface!

    private weak var collectionView: UICollectionView!

    // MARK: - Initializers

    init(_ user: String, _ room: String, _ collectionView: UICollectionView) {

        super.init()

        hmsInterface = HMSInterface(user: user, roomName: room) {
            collectionView.reloadData()
        }

        setup(collectionView)
    }

    func setup(_ collectionView: UICollectionView) {

        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: Constants.resuseIdentifier)

        collectionView.dataSource = self
        collectionView.delegate = self

        self.collectionView = collectionView
    }

    // MARK: - View Modifiers

    // MARK: - Action Handlers

    func cleanup() {
        hmsInterface.cleanup()
    }
}

extension MeetingViewModel: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hmsInterface.videoTracks.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.resuseIdentifier,
                                                            for: indexPath) as? VideoCollectionViewCell,
              indexPath.item < hmsInterface.videoTracks.count
        else {
            return UICollectionViewCell()
        }
        let track = hmsInterface.videoTracks[indexPath.item]

        cell.videoView.setVideoTrack(track)

        return cell
    }
}

extension MeetingViewModel: UICollectionViewDelegate {

}

extension MeetingViewController: UICollectionViewDelegateFlowLayout {

    var sectionInsets: UIEdgeInsets {
        UIEdgeInsets(top: 15.0, left: 8.0, bottom: 15.0, right: 8.0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingSpace = sectionInsets.left * 3
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / 2

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return sectionInsets.left
    }
}
