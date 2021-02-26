//
//  VideoCollectionViewCell.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import HMSVideo

class VideoCollectionViewCell: UICollectionViewCell {
    lazy var videoView: HMSVideoView = {
        return HMSVideoView()
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.clipsToBounds = true

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
