//
//  MeetingViewModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

final class MeetingViewModel: NSObject,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    private var hms: HMSInterface!

    private weak var collectionView: UICollectionView!

    private let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    // MARK: - Initializers

    init(_ user: String, _ room: String, _ collectionView: UICollectionView) {

        super.init()

        hms = HMSInterface(user: user, roomName: room) {
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hms.videoTracks.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.resuseIdentifier,
                                                            for: indexPath) as? VideoCollectionViewCell,
              indexPath.item < hms.videoTracks.count
        else {
            return UICollectionViewCell()
        }

        let track = hms.videoTracks[indexPath.item]

        cell.videoView.setVideoTrack(track)

        Utilities.applyBorder(on: cell)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let widthInsets = sectionInsets.left + sectionInsets.right
        let heightInsets = sectionInsets.top + sectionInsets.bottom

        if hms.videoTracks.count < 5 {
            return CGSize(width: collectionView.frame.size.width - widthInsets,
                          height: (collectionView.frame.size.height / CGFloat(hms.videoTracks.count)) - heightInsets)
        } else {
            return CGSize(width: (collectionView.frame.size.width / 2) - widthInsets,
                          height: (collectionView.frame.size.height / 3) - heightInsets)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    // MARK: - Action Handlers

    func cleanup() {
        hms.cleanup()
    }

    func switchCamera() {
        hms.switchCamera()
    }

    func switchAudio(isOn: Bool) {
        hms.switchAudio(isOn)
    }

    func switchVideo(isOn: Bool) {
        hms.switchVideo(isOn)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
