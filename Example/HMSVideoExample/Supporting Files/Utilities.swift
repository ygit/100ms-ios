//
//  Utilities.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import QuartzCore

class Utilities {

    static func applyBorder(on view: UIView) {
        if #available(iOS 11.0, *) {
            view.layer.borderColor = UIColor(named: "Border")?.cgColor
        } else {
            view.layer.borderColor = UIColor.black.cgColor
        }

        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }

    static func drawCorner(on view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }
}
