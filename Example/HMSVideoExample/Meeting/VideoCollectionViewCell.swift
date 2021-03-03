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

    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            contentView.bringSubviewToFront(nameLabel)
        }
    }

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
}
