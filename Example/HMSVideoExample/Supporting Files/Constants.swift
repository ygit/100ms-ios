//
//  Constants.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation

struct Constants {

    static let token = "https://ms-services-r9oucbp9pjl9.runkit.sh/?api=token"

    static let endpoint = "wss://prod-in.100ms.live/ws"

    // MARK: - View Constants

    static let meeting = "Meeting"

    static let emptyFields = "Please fill in all fields!"

    static let meetingError = "Could not make Meeting View Controller!"

    static let resuseIdentifier = "videoCell"

    // MARK: - HMS Interface

    static let urlEmpty = "Token & Endpoint URLs cannot be nil!"

    static let jsonError = "JSON Data parsing error!"

    static let hmsError = NSNotification.Name("HMS_ERROR")

}
