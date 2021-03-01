//
//  MeetingViewModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

enum Layout {
    case grid, portrait
}

final class MeetingViewModel: NSObject,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    private(set) var hms: HMSInterface!

    private weak var collectionView: UICollectionView!

    private let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    var layout = Layout.grid {
        didSet {
            collectionView.reloadData()
        }
    }

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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        layout == .grid ? 1 : 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch layout {
        case .grid:
            return hms.videoTracks.count
        case .portrait:
            if hms.videoTracks.count == 0 {
                return 0
            }
            return section == 0 ? 1 : (hms.videoTracks.count - 1)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.resuseIdentifier,
                                                            for: indexPath) as? VideoCollectionViewCell,
               indexPath.item < hms.videoTracks.count
        else {
            return UICollectionViewCell()
        }

        switch layout {
        case .grid:
            let track = hms.videoTracks[indexPath.item]
            cell.videoView.setVideoTrack(track)
        case .portrait:
            if indexPath.section == 0 {
                let track = hms.videoTracks[indexPath.row]
                cell.videoView.setVideoTrack(track)
            } else {
                let track = hms.videoTracks[indexPath.row+1]
                cell.videoView.setVideoTrack(track)
            }
        }

        Utilities.applyBorder(on: cell)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let widthInsets = sectionInsets.left + sectionInsets.right
        let heightInsets = sectionInsets.top + sectionInsets.bottom

        switch layout {
        case .grid:
            if hms.videoTracks.count < 5 {
                let count = CGFloat(hms.videoTracks.count)
                return CGSize(width: collectionView.frame.size.width - widthInsets,
                              height: (collectionView.frame.size.height / count) - heightInsets)
            } else {
                let rows = UserDefaults.standard.object(forKey: Constants.maximumRows) as? CGFloat ?? 3.0
                return CGSize(width: (collectionView.frame.size.width / 2) - widthInsets,
                              height: (collectionView.frame.size.height / rows) - heightInsets)
            }

        case .portrait:
            let rows = CGFloat(min(hms.videoTracks.count, 4))
            let commonWidth = collectionView.frame.size.width / rows - widthInsets
            let commonHeight = commonWidth * 3.0 / 4.0

            switch indexPath.section {
            case 0:
                return CGSize(width: collectionView.frame.size.width - widthInsets,
                              height: collectionView.frame.size.height - commonHeight - heightInsets)
            default:
                return CGSize(width: commonWidth, height: commonHeight)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        switch layout {
        case .grid:
            return sectionInsets

        case .portrait:

            switch section {
            case 0:
                return sectionInsets
            default:

                let width = collectionView.frame.size.width
                let widthInsets = sectionInsets.left + sectionInsets.right

                let columns = CGFloat(min(hms.videoTracks.count - 1, 4))
                let cellWidth = (width / columns)

                let cellInsets = 2*widthInsets*columns

                let inset = (width - cellWidth - cellInsets) / columns

                return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
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
