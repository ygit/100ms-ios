//
//  HMSWrapper.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSVideo

struct HMSWrapper {
    
    let endpoint: String
    let token: String
    let user: String
    let roomName: String
    
    var localPeer: HMSPeer!
    var client: HMSClient!
    var room: HMSRoom!
    
    private(set) var peers = [String: HMSPeer]()
    private(set) var remoteStreams = [HMSStream]()
    private(set) var videoTracks = [HMSVideoTrack]()
    private(set) var localStream: HMSStream?
    private(set) var localAudioTrack: HMSAudioTrack?
    private(set) var localVideoTrack: HMSVideoTrack?
    private(set) var videoCapturer: HMSVideoCapturer?
    
    private(set) var speaker: String?
    
    
    
    func fetchToken(completion: @escaping (String?, Error?) -> Void) {
        
        guard let endpointURL = URL(string: endpoint),
              let tokenURL = URL(string: token),
              let subDomain = endpointURL.host?.components(separatedBy: ".").first
        else {
            print(Constants.urlEmpty)
            completion(nil, get(error: Constants.urlEmpty))
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
            completion(nil, get(error: error.localizedDescription))
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            parseToken(from: data, error: error) { (token, error) in
                DispatchQueue.main.async {
                    completion(token, error)
                }
            }
            
        }).resume()
    }
    
    func parseToken(from data: Data?, error: Error?, completion: @escaping (String?, Error?) -> Void) {
        
        guard error == nil, let data = data else {
            print("\(String(describing: error))")
            completion(nil, get(error: error!.localizedDescription))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data,
                                                           options: .mutableContainers) as? [String: Any] {
                if let token = json["token"] as? String {
                    completion(token, nil)
                } else {
                    print(Constants.jsonError)
                    completion(nil, get(error: Constants.jsonError))
                }
            }
        } catch {
            print(error.localizedDescription)
            completion(nil, get(error: error.localizedDescription))
        }
    }
    
    
    
    mutating func connect(with token: String, update callback: @escaping () -> Void) {
        
        localPeer = HMSPeer(name: user, authToken: token)
        
        let config = HMSClientConfig()
        config.endpoint = endpoint
        
        client = HMSClient(peer: localPeer, config: config)
        client.logLevel = .verbose
        
        room = HMSRoom(roomId: roomName)
        
        client.onPeerJoin = { room, peer in
            callback()
        }
        
        client.onPeerLeave = { room, peer in
            callback()
        }
        
        client.onStreamAdd = { room, peer, info in
            
            self.subscribe(to: room, peer, with: info) {
                callback()
            }
        }
        
        client.onStreamRemove = { room, peer, info in
            
            videoTracks.removeAll { $0.streamId == info.streamId }
            callback()
        }
        
        client.onBroadcast = { room, peer, data in
            callback()
        }
        
        client.onConnect = {
            client.join(room) { succes, error in
                self.publish() {
                    callback()
                }
            }
        }
        
        client.onDisconnect = { error in
            self.showDisconnectError(error)
            callback()
        }
        
        client.onAudioLevelInfo = { levels in
            self.updateAudio(with: levels)
            callback()
        }
        
        client.connect()
    }
    
    
    mutating func subscribe(to room: HMSRoom, _ peer: HMSPeer, with info: HMSStreamInfo,
                            completion: @escaping () -> Void) {
        
        peers[info.streamId] = peer
        
        client.subscribe(info, room: room) { (stream, error) in
            
            guard let stream = stream,
                  let videoTrack = stream.videoTracks?.first
            else {
                return
            }
            
            self.remoteStreams.append(stream)
            self.videoTracks.append(videoTrack)
            completion()
        }
    }
    
    
    mutating func publish(completion: @escaping () -> Void) {
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
            
            self.setupLocal(stream) {
                completion()
            }
        }
    }
    
    mutating func setupLocal(_ stream: HMSStream, completion: @escaping () -> Void) {
        localStream = stream
        videoCapturer = stream.videoCapturer
        localAudioTrack = stream.audioTracks?.first
        localVideoTrack = stream.videoTracks?.first

        videoCapturer?.startCapture()
        
        if let track = localVideoTrack {
            videoTracks.append(track)
            completion()
        }
    }
    
    mutating func updateAudio(with levels: [HMSAudioLevelInfo]) {
        
        guard let topLevel = levels.first,
              let peer = peers[topLevel.streamId]
        else {
            return
        }
        
        speaker = peer.name
    }
    
    func get(error message: String) -> Error {
        return CustomError(title: message)
    }
}
