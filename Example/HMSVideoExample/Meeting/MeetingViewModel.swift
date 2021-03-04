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

    private(set) var hms: HMSInteractor!

    weak var collectionView: UICollectionView?

    private let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    internal var layout = Layout.grid {
        didSet {
            collectionView?.reloadData()
        }
    }

    // MARK: - Initializers

    init(_ user: String, _ room: String, _ flow: MeetingFlow, _ collectionView: UICollectionView) {

        super.init()

        hms = HMSInteractor(for: user, in: room, flow) { [weak self] state in
            self?.updateView(for: state)
        }

        setup(collectionView)
    }

    func setup(_ collectionView: UICollectionView) {

        collectionView.dataSource = self
        collectionView.delegate = self

        self.collectionView = collectionView
    }

    // MARK: - View Modifiers

    func updateView(for state: VideoCellState) {

        switch state {

        case .insert(let index):

            print(#function, index)
            collectionView?.insertItems(at: [IndexPath(item: index, section: 0)])

        case .delete(let index):

            print(#function, index)
            collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])

        case .refresh(let indexes):

            print(#function, indexes)

            let oldIndex = IndexPath(item: indexes.0, section: 0)
            let newIndex = IndexPath(item: indexes.1, section: 0)

            if let oldCell = collectionView?.cellForItem(at: oldIndex) as? VideoCollectionViewCell {
                oldCell.isSpeaker = false
            }
            if let newCell = collectionView?.cellForItem(at: newIndex) as? VideoCollectionViewCell {
                newCell.isSpeaker = true
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hms.videoTracks.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.resuseIdentifier,
                                                            for: indexPath) as? VideoCollectionViewCell,
               indexPath.item < hms.videoTracks.count
        else {
            return UICollectionViewCell()
        }

        updateCell(at: indexPath, for: cell)

        return cell
    }

    func updateCell(at indexPath: IndexPath, for cell: VideoCollectionViewCell) {

        let track = hms.videoTracks[indexPath.row]

        switch layout {
        case .grid:
            cell.videoView.setVideoTrack(track)
        case .portrait:
            if indexPath.section == 0 {
                cell.videoView.setVideoTrack(track)
            } else {
                let track = hms.videoTracks[indexPath.row+1]
                cell.videoView.setVideoTrack(track)
            }
        }

        let streamID = track.streamId
        let peer = hms.peers[streamID]
        cell.nameLabel.text = peer?.name

        cell.isSpeaker = track.trackId == hms.speakerVideoTrack?.trackId
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
            if hms.videoTracks.count < 3 {
                let count = CGFloat(hms.videoTracks.count)
                return CGSize(width: collectionView.frame.size.width - widthInsets,
                              height: (collectionView.frame.size.height / count) - heightInsets)
            } else {
                let rows = UserDefaults.standard.object(forKey: Constants.maximumRows) as? CGFloat ?? 2.0
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

                if hms.videoTracks.count < 5 {
                    let width = collectionView.frame.size.width
                    let widthInsets = sectionInsets.left + sectionInsets.right

                    let columns = CGFloat(min(hms.videoTracks.count - 1, 4))
                    let cellWidth = (width / columns)

                    let cellInsets = 2*widthInsets*columns

                    let inset = (width - cellWidth - cellInsets) / columns

                    return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
                }

                return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
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
        if let capturer = hms.localStream?.videoCapturer {
            capturer.switchCamera()
        }
    }

    func switchAudio(isOn: Bool) {
        if let audioTrack = hms.localStream?.audioTracks?.first {
            audioTrack.enabled = isOn
        }
    }

    func switchVideo(isOn: Bool) {
        if let videoTrack = hms.localStream?.videoTracks?.first {
            videoTrack.enabled = isOn
        }
    }
}
