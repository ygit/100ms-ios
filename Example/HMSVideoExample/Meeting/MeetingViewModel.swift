//
//  MeetingViewModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

final class MeetingViewModel: NSObject {

    private(set) var wrapper: HMSWrapper

    // MARK: - Initializers

    init(endpoint: String, token: String, user: String, room: String) {

        wrapper = HMSWrapper(endpoint: endpoint, token: token, user: user, roomName: room) {

            // TODO: update UI
        }
    }

    func setup(_ collectionView: UICollectionView) {
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: Constants.resuseIdentifier)

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - View Modifiers

    // MARK: - Action Handlers

    func cleanup() {
        wrapper.cleanup()
    }
}

extension MeetingViewModel: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension MeetingViewModel: UICollectionViewDelegate {

}

extension MeetingViewController: UICollectionViewDelegateFlowLayout {

    var sectionInsets: UIEdgeInsets {
        get {
            UIEdgeInsets(top: 15.0, left: 8.0, bottom: 15.0, right: 8.0)
        }
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
