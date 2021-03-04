//
//  HMSInteractor.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSVideo

final class HMSInteractor {

    // MARK: - Instance Properties

    private let user: String

    private var updateView: (VideoCellState) -> Void

    private(set) var localPeer: HMSPeer!
    private(set) var client: HMSClient!
    private(set) var room: HMSRoom! {
        didSet {
            let pasteboard = UIPasteboard.general
            pasteboard.string = room.roomId
        }
    }

    private(set) var peers = [String: HMSPeer]()
    private(set) var remoteStreams = [HMSStream]()
    private(set) var videoTracks = [HMSVideoTrack]()

    var model = [VideoModel]()

    private(set) var localStream: HMSStream?
    private(set) var localAudioTrack: HMSAudioTrack?
    private(set) var localVideoTrack: HMSVideoTrack?
    private(set) var videoCapturer: HMSVideoCapturer?

    private(set) var speakerPeerID: String? {
        didSet {
            let streamer = peers.filter { $0.value.peerId == speakerPeerID }
            if let streamID = streamer.keys.first {
                if let track = videoTracks.filter({ $0.streamId == streamID }).first {
                    if speakerVideoTrack?.trackId != track.trackId {
                        speakerVideoTrack = track
                    }
                }
            }
        }
    }

    private(set) var speakerVideoTrack: HMSVideoTrack? {
        didSet {
            if let oldValue = oldValue, let speakerVideoTrack = speakerVideoTrack {

                if let oldIndex = model.firstIndex(where: { $0.videoTrack.trackId == oldValue.trackId }),
                   let newIndex = model.firstIndex(where: { $0.videoTrack.trackId == speakerVideoTrack.trackId }) {
                    if oldIndex != newIndex {
                        model[oldIndex].isCurrentSpeaker = false
                        model[newIndex].isCurrentSpeaker = true
                        updateView(.refresh(indexes: (oldIndex, newIndex)))
                    }
                }
            }
        }
    }

    private var codec: HMSVideoCodec {
        let codecString = UserDefaults.standard.string(forKey: Constants.videoCodec) ?? "VP8"

        switch codecString {
        case "H264":
            return .H264
        case "VP9":
            return .VP9
        default:
            return .VP8
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

    private var cameraSource = "Front Facing" {
        willSet {
            if newValue != cameraSource {
                videoCapturer?.switchCamera()
            }
        }
    }

    internal var broadcasts = [[AnyHashable: Any]]()

    private var flow: MeetingFlow

    // MARK: - Setup Stream

    init(for user: String, in room: String, _ flow: MeetingFlow, _ callback: @escaping (VideoCellState) -> Void) {

        self.user = user
        self.flow = flow
        self.updateView = callback

        setup(room)

        observeSettingsUpdated()
    }

    func setup(_ room: String) {

        switch flow {
        case .join:
            fetchToken(Constants.endpoint, Constants.getTokenURL, room) { [weak self] token, error in

                guard error == nil, let token = token, let strongSelf = self
                else {
                    let error = error ?? CustomError(title: "Fetch Token Error")
                    NotificationCenter.default.post(name: Constants.hmsError,
                                                    object: nil,
                                                    userInfo: ["Error": error])
                    return
                }
                strongSelf.connect(with: token, room)
            }
        case .start:
            createRoom(name: room) { [weak self] _, roomID, error in

                guard error == nil, let roomID = roomID, let strongSelf = self
                else {
                    let error = error ?? CustomError(title: "Create Room Error")
                    NotificationCenter.default.post(name: Constants.hmsError,
                                                    object: nil,
                                                    userInfo: ["Error": error])
                    return
                }

                strongSelf.fetchToken(Constants.endpoint, Constants.getTokenURL, roomID) { [weak self] token, error in
                    guard error == nil, let token = token, let strongSelf = self
                    else {
                        let error = error ?? CustomError(title: "Fetch Token Error")
                        NotificationCenter.default.post(name: Constants.hmsError,
                                                        object: nil,
                                                        userInfo: ["Error": error])
                        return
                    }

                    strongSelf.connect(with: token, roomID)
                }
            }
        }
    }

    func fetchToken(_ endpoint: String,
                    _ token: String,
                    _ roomID: String,
                    completion: @escaping (String?, Error?) -> Void) {

        guard let endpointURL = URL(string: endpoint),
              let tokenURL = URL(string: token),
              let subDomain = endpointURL.host?.components(separatedBy: ".").first
        else {
            completion(nil, CustomError(title: Constants.urlEmpty))
            return
        }

        let body = [  "room_id": roomID,
                      "user_name": user,
                      "role": "guest",
                      "env": subDomain    ]

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
            completion(nil, CustomError(title: error.localizedDescription))
            return
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in

            self?.parseToken(from: data, error: error) { token, error in
                DispatchQueue.main.async {
                    completion(token, error)
                }
            }
        }.resume()
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

    func createRoom(name: String, completion: @escaping (Bool, String?, Error?) -> Void) {

        guard let createRoomURL = URL(string: Constants.createRoomURL)
        else {
            completion(false, nil, CustomError(title: "Create Room URL Error"))
            return
        }

        let cleanedName = name.replacingOccurrences(of: " ", with: "")

        let body = [
                "room_id": cleanedName,
                "user_name": user,
                "role": "host",
                "env": "prod-in"
                ]

        var request = URLRequest(url: createRoomURL)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
            completion(false, nil, CustomError(title: error.localizedDescription))
            return
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in

            self?.parseRooms(data, error) { isSucces, roomID, error in
                completion(isSucces, roomID, error)
            }
        }.resume()
    }

    func parseRooms(_ data: Data?, _ error: Error?, completion: (Bool, String?, Error?) -> Void) {
        guard error == nil, let data = data else {
            let message = error?.localizedDescription ?? "Parse Create Room Response Error"
            completion(false, nil, CustomError(title: message))
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data,
                                                           options: .mutableContainers) as? [String: Any] {
                if let roomID = json["id"] as? String {
                    completion(true, roomID, nil)
                } else {
                    print(Constants.jsonError)
                    completion(false, nil, CustomError(title: Constants.jsonError))
                }
            }
        } catch {
            print(error.localizedDescription)
            completion(false, nil, CustomError(title: error.localizedDescription))
        }
    }

    // MARK: - Stream Handlers

    func connect(with token: String, _ roomID: String) {

        localPeer = HMSPeer(name: user, authToken: token)

        let config = HMSClientConfig()
        config.endpoint = Constants.endpoint

        client = HMSClient(peer: localPeer, config: config)
        client.logLevel = .verbose

        room = HMSRoom(roomId: roomID)

        setupCallbacks()

        setAudioDelay()

        client.connect()
    }

    func setupCallbacks() {
        client.onPeerJoin = { room, peer in
            print("onPeerJoin: ", room.roomId, peer.name)
            NotificationCenter.default.post(name: Constants.peersUpdated, object: nil)
        }

        client.onPeerLeave = { room, peer in
            print("onPeerLeave: ", room.roomId, peer.name)
            NotificationCenter.default.post(name: Constants.peersUpdated, object: nil)
        }

        client.onStreamAdd = { [weak self] room, peer, info in
            print("onStreamAdd: ", room.roomId, peer.name, info.streamId)
            self?.subscribe(to: room, peer, with: info)
        }

        client.onStreamRemove = { [weak self] room, peer, info in

            print("onStreamRemove: ", room.roomId, peer.name, info.streamId)

            if let videoTracks = self?.videoTracks {

                for (index, track) in videoTracks.enumerated() where track.streamId == info.streamId {
                    self?.videoTracks.remove(at: index)
                }

                var indexes = [Int]()
                if let model = self?.model {
                    for (index, item) in model.enumerated() where item.videoTrack.streamId == info.streamId {
                        self?.model.remove(at: index)
                        indexes.append(index)
                    }
                }

                indexes.forEach { self?.updateView(.delete(index: $0)) }
            }
        }

        client.onBroadcast = { [weak self] room, peer, data in
            print("onBroadcast: ", room.roomId, peer.peerId, data)
            self?.broadcasts.append(data)
            NotificationCenter.default.post(name: Constants.broadcastReceived, object: nil)
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

        client.onAudioLevelInfo = { [weak self] levels in
            self?.updateAudio(with: levels)
        }
    }

    func subscribe(to room: HMSRoom, _ peer: HMSPeer, with info: HMSStreamInfo) {

        peers[info.streamId] = peer

        client.subscribe(info, room: room) { [weak self] (stream, error) in

            guard let stream = stream,
                  let videoTrack = stream.videoTracks?.first
            else {
                print(error?.localizedDescription ?? "Client Subscribe Error")
                return
            }

            self?.remoteStreams.append(stream)
            self?.videoTracks.append(videoTrack)

            let item = VideoModel(peer: peer, videoTrack: videoTrack)
            self?.model.append(item)
            self?.updateView(.insert(index: (self?.model.count ?? 1) - 1))
        }
    }

    func publish() {

        let userDefaults = UserDefaults.standard

        let constraints = HMSMediaStreamConstraints()
        constraints.shouldPublishAudio = userDefaults.object(forKey: Constants.publishAudio) as? Bool ?? true
        constraints.shouldPublishVideo = userDefaults.object(forKey: Constants.publishVideo) as? Bool ?? true
        constraints.bitrate = userDefaults.object(forKey: Constants.videoBitRate) as? Int ?? 256
        constraints.audioBitrate = userDefaults.object(forKey: Constants.audioBitRate) as? Int ?? 0
        constraints.frameRate = userDefaults.object(forKey: Constants.videoFrameRate) as? Int ?? 25
        constraints.resolution = resolution
        constraints.codec = codec

        guard let localStream = try? client.getLocalStream(constraints) else {
            return
        }

        peers[localStream.streamId] = localPeer

        let audioPollDelay = userDefaults.object(forKey: Constants.audioPollDelay) as? Double ?? 0.5
        client.startAudioLevelMonitor(audioPollDelay)

        client.publish(localStream, room: room) { stream, error in
            guard let stream = stream else {
                print(error?.localizedDescription ?? "Local Stream publish failed")
                return
            }

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
                cameraSource = "Rear Facing"
            } else {
                cameraSource = "Front Facing"
            }
        }

        videoCapturer?.startCapture()

        if let track = localVideoTrack {
            videoTracks.append(track)

            guard let peer = peers[stream.streamId] else {
                print("Error: Could not find local peer!")
                return
            }

            let item = VideoModel(peer: peer, videoTrack: track)
            model.append(item)

            let lastIndex = model.count > 0 ? model.count : 1
            updateView(.insert(index: lastIndex - 1))
        }
    }
}

// MARK: - Action Handlers

extension HMSInteractor {

    func updateAudio(with levels: [HMSAudioLevelInfo]) {

        guard let topLevel = levels.first,
              let peer = peers[topLevel.streamId]
        else {
            return
        }

        speakerPeerID = peer.peerId

        print("Speaker: ", peer.name)
    }

    func observeSettingsUpdated() {
        _ = NotificationCenter.default.addObserver(forName: Constants.settingsUpdated,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in

            let userDefaults = UserDefaults.standard

            let constraints = HMSMediaStreamConstraints()

            constraints.bitrate = userDefaults.object(forKey: Constants.videoBitRate) as? Int ?? 256
            constraints.audioBitrate = userDefaults.object(forKey: Constants.audioBitRate) as? Int ?? 0
            constraints.frameRate = userDefaults.object(forKey: Constants.videoFrameRate) as? Int ?? 25
            constraints.resolution = self?.resolution ?? .QHD

            do {
                if let strongSelf = self, let stream = self?.localStream {
                    try strongSelf.client.applyConstraints(constraints, to: stream)
                }
            } catch {
                NotificationCenter.default.post(name: Constants.hmsError, object: nil, userInfo: ["Error": error])
            }

            if let source = UserDefaults.standard.string(forKey: Constants.defaultVideoSource) {
                self?.cameraSource = source
            }

            self?.setAudioDelay()
        }
    }

    func setAudioDelay() {
        let audioPollDelay = UserDefaults.standard.object(forKey: Constants.audioPollDelay) as? Double ?? 3.0
        client.startAudioLevelMonitor(audioPollDelay)
    }

    func send(_ broadcast: [AnyHashable: Any], completion: @escaping () -> Void) {

        client.broadcast(broadcast, room: room) { _, error in

            if let error = error {
                print(error.localizedDescription)
            }
            completion()
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
