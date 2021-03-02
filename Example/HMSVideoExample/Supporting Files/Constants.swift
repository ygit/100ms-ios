//
//  Constants.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation

struct Constants {

    // MARK: - HMS Interactor

    static let server = "https://ms-services-r9oucbp9pjl9.runkit.sh/"

    static let endpoint = "wss://"+(UserDefaults.standard.string(forKey: "environment") ?? "prod-in")+".100ms.live/ws"

    static let getToken = server + "?api=token"

    static let createRoom = server + "?api=room"

    static let urlEmpty = "Token & Endpoint URLs cannot be nil!"

    static let jsonError = "JSON Data parsing error!"

    static let hmsError = NSNotification.Name("HMS_ERROR")

    static let settingsUpdated = NSNotification.Name("SETTINGS_UPDATED")

    static let broadcastReceived = NSNotification.Name("BROADCAST_RECEIVED")

    static let peersUpdated = NSNotification.Name("PEERS_UPDATED")

    // MARK: - View Constants

    static let meeting = "Meeting"

    static let settings = "Settings"

    static let chat = "Chat"

    static let participants = "Participants"

    static let emptyFields = "Please fill in all fields!"

    static let meetingError = "Could not make Meeting View Controller!"

    static let resuseIdentifier = "Cell"

    static let chatSenderName = "senderName"

    static let chatMessage = "msg"

    // MARK: - Settings

    static let defaultName = "defaultName"

    static let roomName = "roomName"

    static let publishVideo = "publishVideo"

    static let publishAudio = "publishAudio"

    static let maximumRows = "maximumRows"

    static let audioPollDelay = "audioPollDelay"

    static let silenceThreshold = "silenceThreshold"

    static let mirrorMyVideo = "mirrorMyVideo"

    static let showVideoPreview = "showVideoPreview"

    static let videoFrameRate = "videoFrameRate"

    static let environment = "environment"

    static let defaultVideoSource = "defaultVideoSource"

    static let videoCodec = "videoCodec"

    static let videoResolution = "videoResolution"

    static let videoBitRate = "videoBitRate"
}
