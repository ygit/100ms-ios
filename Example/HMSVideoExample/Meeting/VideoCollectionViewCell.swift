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

    private(set) lazy var videoView: HMSVideoView = {
        HMSVideoView()
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.clipsToBounds = true
        contentView.contentMode = .scaleAspectFit

        if videoView.superview == nil {
            contentView.addSubview(videoView)
            videoView.translatesAutoresizingMaskIntoConstraints = false

            videoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            videoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            videoView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            videoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
    }
}
