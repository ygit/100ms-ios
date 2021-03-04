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

    static let server = UserDefaults.standard.string(forKey: serverURLKey) ?? "https://100ms-services.vercel.app/"
//    "https://ms-services-server-token-17sgcgfb18ow.runkit.sh/"
//    https://100ms-services.vercel.app/api/room_token

    static let endpoint = UserDefaults.standard.string(forKey: socketEndpointKey) ?? "wss://qa-in.100ms.live/ws"

    static let tokenQuery = UserDefaults.standard.string(forKey: tokenQueryKey) ?? "api/token"
    //    static let getToken = server + "?api=token"

    static let getTokenURL = server + tokenQuery

    static let createRoomQuery = UserDefaults.standard.string(forKey: createRoomQueryKey) ?? "api/room_token"
    //    static let createRoom = server + "?api=room"

    static let createRoomURL = server + createRoomQuery

    static let urlEmpty = "Token & Endpoint URLs cannot be nil!"

    static let jsonError = "JSON Data parsing error!"

    // MARK: - Notifications

    static let hmsError = NSNotification.Name("HMS_ERROR")

    static let settingsUpdated = NSNotification.Name("SETTINGS_UPDATED")

    static let broadcastReceived = NSNotification.Name("BROADCAST_RECEIVED")

    static let peersUpdated = NSNotification.Name("PEERS_UPDATED")

    static let speakerUpdated = NSNotification.Name("SPEAKER_UPDATED")

    static let pinTapped = NSNotification.Name("PIN_TAPPED")

    static let muteTapped = NSNotification.Name("MUTE_TAPPED")

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

    static let index = "index"

    // MARK: - Settings

    static let defaultName = "defaultName"

    static let serverURLKey = "serverURL"

    static let socketEndpointKey = "socketEndpoint"

    static let tokenQueryKey = "getToken"

    static let createRoomQueryKey = "createRoom"

    static let roomName = "roomName"

    static let publishVideo = "publishVideo"

    static let publishAudio = "publishAudio"

    static let maximumRows = "maximumRows"

    static let audioPollDelay = "audioPollDelay"

    static let silenceThreshold = "silenceThreshold"

    static let mirrorMyVideo = "mirrorMyVideo"

    static let showVideoPreview = "showVideoPreview"

    static let videoFrameRate = "videoFrameRate"

    static let audioBitRate = "audioBitRate"

    static let defaultVideoSource = "defaultVideoSource"

    static let videoCodec = "videoCodec"

    static let videoResolution = "videoResolution"

    static let videoBitRate = "videoBitRate"
}
