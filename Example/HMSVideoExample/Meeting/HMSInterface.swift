//
//  HMSWrapper.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSVideo

final class HMSInterface {

    // MARK: - Instance Properties

    private let user: String
    private let roomName: String

    private var updateUI: () -> Void

    private(set) var localPeer: HMSPeer!
    private(set) var client: HMSClient!
    private(set) var room: HMSRoom!

    private(set) var peers = [String: HMSPeer]()
    private(set) var remoteStreams = [HMSStream]()
    private(set) var videoTracks = [HMSVideoTrack]() {
        didSet {
            updateUI()
        }
    }

    private(set) var localStream: HMSStream?
    private(set) var localAudioTrack: HMSAudioTrack?
    private(set) var localVideoTrack: HMSVideoTrack?
    private(set) var videoCapturer: HMSVideoCapturer?

    private(set) var speaker: String?

    private var codec: HMSVideoCodec {
        let codecString = UserDefaults.standard.string(forKey: Constants.videoCodec) ?? "VP8"

        switch codecString {
        case "VP8":
            return .VP8
        case "VP9":
            return .VP9
        default:
            return .H264
        }
    }

    private var resolution: HMSVideoResolution {
        let resolutionString = UserDefaults.standard.string(forKey: Constants.videoResolution) ?? "QHD"

        switch resolutionString {
        case "QVGA":
            return .QVGA
        case "VGA":
            return .VGA
        case "HD":
            return .HD
        case "Full HD":
            return .fullHD
        default:
            return .QHD
        }
    }

    // MARK: - Setup Stream

    init(user: String, roomName: String, callback: @escaping () -> Void) {

        self.user = user
        self.roomName = roomName
        self.updateUI = callback

        fetchToken { [weak self] token, error in

            guard error == nil, let token = token
            else {
                let error = error ?? CustomError(title: "Fetch Token Error")
                NotificationCenter.default.post(name: Constants.hmsError, object: nil, userInfo: ["Error": error])
                return
            }

            self?.connect(with: token)
        }
    }

    func fetchToken(completion: @escaping (String?, Error?) -> Void) {

        guard let endpointURL = URL(string: Constants.endpoint),
              let tokenURL = URL(string: Constants.token),
              let subDomain = endpointURL.host?.components(separatedBy: ".").first
        else {
            completion(nil, CustomError(title: Constants.urlEmpty))
            return
        }

        let parameters = [  "room_id": roomName,
                            "user_name": user,
                            "role": "guest",
                            "env": subDomain    ]

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
            completion(nil, CustomError(title: error.localizedDescription))
            return
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { [weak self] data, _, error in

            self?.parseToken(from: data, error: error) { token, error in
                DispatchQueue.main.async {
                    completion(token, error)
                }
            }

        }).resume()
    }

    func parseToken(from data: Data?, error: Error?, completion: @escaping (String?, Error?) -> Void) {

        guard error == nil, let data = data else {
            let message = error?.localizedDescription ?? "Parse Token Error"
            completion(nil, CustomError(title: message))
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data,
                                                           options: .mutableContainers) as? [String: Any] {
                if let token = json["token"] as? String {
                    completion(token, nil)
                } else {
                    print(Constants.jsonError)
                    completion(nil, CustomError(title: Constants.jsonError))
                }
            }
        } catch {
            print(error.localizedDescription)
            completion(nil, CustomError(title: error.localizedDescription))
        }
    }

    // MARK: - Stream Handlers

    func connect(with token: String) {

        localPeer = HMSPeer(name: user, authToken: token)

        let config = HMSClientConfig()
        config.endpoint = Constants.endpoint

        client = HMSClient(peer: localPeer, config: config)
        client.logLevel = .verbose

        room = HMSRoom(roomId: roomName)

        client.onPeerJoin = { room, peer in
            print("onPeerJoin: ", room.roomId, peer.name)
        }

        client.onPeerLeave = { room, peer in
            print("onPeerLeave: ", room.roomId, peer.name)
        }

        client.onStreamAdd = { room, peer, info in
            print("onStreamAdd: ", room.roomId, peer.name, info.streamId)
            self.subscribe(to: room, peer, with: info)
        }

        client.onStreamRemove = { [weak self] room, peer, info in
            print("onStreamRemove: ", room.roomId, peer.name, info.streamId)
            self?.videoTracks.removeAll { $0.streamId == info.streamId }
        }

        client.onBroadcast = { room, peer, data in
            print("onBroadcast: ", room.roomId, peer.peerId, data)
        }

        client.onConnect = { [weak self] in
            self?.client.join((self?.room)!) { isSuccess, error in
                print("client.join: ", isSuccess, error ?? "No Error")
                self?.publish()
            }
        }

        client.onDisconnect = { error in

            let message = error?.localizedDescription ?? "Client disconnected!"

            NotificationCenter.default.post(name: Constants.hmsError,
                                            object: nil,
                                            userInfo: ["error": message])
        }

        client.onAudioLevelInfo = { levels in
            self.updateAudio(with: levels)
        }

        client.connect()
        client.startAudioLevelMonitor(0.5)
    }

    func subscribe(to room: HMSRoom, _ peer: HMSPeer, with info: HMSStreamInfo) {

        peers[info.streamId] = peer

        client.subscribe(info, room: room) { (stream, _) in

            guard let stream = stream,
                  let videoTrack = stream.videoTracks?.first
            else {
                return
            }

            self.remoteStreams.append(stream)
            self.videoTracks.append(videoTrack)
        }
    }

    func publish() {

        let userDefaults = UserDefaults.standard

        let constraints = HMSMediaStreamConstraints()
        constraints.shouldPublishAudio = userDefaults.object(forKey: Constants.publishAudio) as? Bool ?? true
        constraints.shouldPublishVideo = userDefaults.object(forKey: Constants.publishVideo) as? Bool ?? true
        constraints.codec = codec
        constraints.bitrate = userDefaults.object(forKey: Constants.videoBitRate) as? Int ?? 256
        constraints.frameRate = userDefaults.object(forKey: Constants.videoFrameRate) as? Int ?? 25
        constraints.resolution = resolution

        guard let localStream = try? client.getLocalStream(constraints) else {
            return
        }

        peers[localStream.streamId] = localPeer

        let audioPollDelay = userDefaults.object(forKey: Constants.audioPollDelay) as? Double ?? 0.5
        client.startAudioLevelMonitor(audioPollDelay)

        client.publish(localStream, room: room) { stream, _ in
            guard let stream = stream else { return }

            self.setupLocal(stream)
        }
    }

    func setupLocal(_ stream: HMSStream) {
        localStream = stream
        videoCapturer = stream.videoCapturer
        localAudioTrack = stream.audioTracks?.first
        localVideoTrack = stream.videoTracks?.first

        if let source = UserDefaults.standard.string(forKey: Constants.defaultVideoSource) {
            if source == "Rear Facing" {
                videoCapturer?.switchCamera()
            }
        }

        videoCapturer?.startCapture()

        if let track = localVideoTrack {
            videoTracks.append(track)
        }
    }

    func updateAudio(with levels: [HMSAudioLevelInfo]) {

        guard let topLevel = levels.first,
              let peer = peers[topLevel.streamId]
        else {
            return
        }

        speaker = peer.name
        print("Speaker: ", peer.name)
    }

    func switchCamera() {
        if let capturer = localStream?.videoCapturer {
            capturer.switchCamera()
        }
    }

    func switchAudio(_ isOn: Bool) {
        if let audioTrack = localStream?.audioTracks?.first {
            audioTrack.enabled = isOn
        }
    }

    func switchVideo(_ isOn: Bool) {
        if let videoTrack = localStream?.videoTracks?.first {
            videoTrack.enabled = isOn
        }
    }

    func cleanup() {
        guard let client = client else {
            return
        }

        videoCapturer?.stopCapture()

        client.leave(room)

        client.disconnect()
    }
}
