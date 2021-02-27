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
            
        }

        client.onPeerLeave = { room, peer in
            
        }

        client.onStreamAdd = { room, peer, info in

            self.subscribe(to: room, peer, with: info)
        }

        client.onStreamRemove = { [weak self] room, peer, info in

            self?.videoTracks.removeAll { $0.streamId == info.streamId }
        }

        client.onBroadcast = { room, peer, data in
            
        }

        client.onConnect = { [weak self] in
            self?.client.join((self?.room)!) { isSuccess, error in
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

        let constraints = HMSMediaStreamConstraints()
        constraints.shouldPublishAudio = true
        constraints.shouldPublishVideo = true
        constraints.codec = .VP8
        constraints.bitrate = 256
        constraints.frameRate = 25
        constraints.resolution = .QVGA

        guard let localStream = try? client.getLocalStream(constraints) else {
            return
        }

        peers[localStream.streamId] = localPeer

        client.startAudioLevelMonitor(0.5)

        client.publish(localStream, room: room) { stream, error in
            guard let stream = stream else { return }

            self.setupLocal(stream)
        }
    }

    func setupLocal(_ stream: HMSStream) {
        localStream = stream
        videoCapturer = stream.videoCapturer
        localAudioTrack = stream.audioTracks?.first
        localVideoTrack = stream.videoTracks?.first

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
