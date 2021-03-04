//
//  VideoCollectionViewCell.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 03/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSVideo

class VideoCollectionViewCell: UICollectionViewCell {

    weak var model: VideoModel?

    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: stackView)
            stackView.backgroundColor = stackView.backgroundColor?.withAlphaComponent(0.5)
        }
    }

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var pinButton: UIButton!

    @IBOutlet weak var muteButton: UIButton!

    @IBOutlet weak var videoView: HMSVideoView!

    var isSpeaker = false {
        didSet {
            if isSpeaker {
                Utilities.applySpeakerBorder(on: videoView)
            } else {
                Utilities.applyBorder(on: videoView)
            }
        }
    }

    @IBAction func pinTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        model?.isPinned = sender.isSelected
        NotificationCenter.default.post(name: Constants.pinTapped,
                                        object: nil,
                                        userInfo: [Constants.index: model?.indexPath])
    }

    @IBAction func muteTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        model?.isMuted = sender.isSelected
        NotificationCenter.default.post(name: Constants.muteTapped,
                                        object: nil,
                                        userInfo: [Constants.index: model?.indexPath])
    }
}
