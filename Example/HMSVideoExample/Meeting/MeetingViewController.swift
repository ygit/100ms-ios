//
//  MeetingViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import HMSVideo

final class MeetingViewController: UIViewController {
    
    
    private var viewModel: MeetingViewModel!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var speakerLabel: UILabel!

    
    
    
    
    var client: HMSClient!

    var videoTrack: HMSVideoTrack?
    var localAudioTrack: HMSAudioTrack?
    var localVideoTrack: HMSVideoTrack?
    var videoCapturer: HMSVideoCapturer?
    var videoTracks = [HMSVideoTrack]()
    var localStream: HMSStream?
    var remoteStreams = [HMSStream]()
    var localPeer: HMSPeer!
    var peers = [String: HMSPeer]()
//    var room: HMSRoom!

    

    private let sectionInsets = UIEdgeInsets(
      top: 15.0,
      left: 8.0,
      bottom: 15.0,
      right: 8.0)
    
    
    // MARK: - View Lifecycle
    
    static func make(with endpoint: String, token: String, user: String, room: String) -> MeetingViewController? {
        guard let viewController = UIStoryboard(name: Constants.meeting, bundle: nil).instantiateInitialViewController() as? MeetingViewController else {
            return nil
        }

        viewController.viewModel = MeetingViewModel(endpoint: endpoint, token: token, user: user, room: room)
        
        return viewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: "videoCell")
    
        NotificationCenter.default.addObserver(forName: Constants.unpublishError, object: nil, queue: .main) { [weak self] notification in
            
            let alertController = UIAlertController(title: "Error", message: "Connection lost: \(error?.localizedDescription ?? "Unknown")", preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action1)
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }

    

    func updateAudioLevels(levels: [HMSAudioLevelInfo]) {
        guard let topLevel = levels.first else {
            return
        }

        guard let peer = peers[topLevel.streamId] else {
            return
        }

        speakerLabel.text = "Speaking: \(peer.name)"
    }

    func showDisconnectError(_ error: Error?) {
        let alertController = UIAlertController(title: "Error", message: "Connection lost: \(error?.localizedDescription ?? "Unknown")", preferredStyle: .alert)

        let action1 = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }

    func showTokenFailedError() {
        let alertController = UIAlertController(title: "Error", message: "Could not fetch token.", preferredStyle: .alert)

        let action1 = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            UIApplication.shared.isIdleTimerDisabled = false
            cleanup()
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

        client.publish(localStream, room: room, completion: { [weak self] (stream, _) in
            guard let stream = stream else { return }

            DispatchQueue.main.async {
                self?.setupLocalStream(stream: stream)
            }
        })
    }

    func setupLocalStream(stream: HMSStream) {
        localStream = stream
        videoCapturer = stream.videoCapturer
        localAudioTrack = stream.audioTracks?.first
        localVideoTrack = stream.videoTracks?.first

        videoCapturer?.startCapture()
        if let track = localVideoTrack {
            addVideoTrack(track)
        }
    }

    func subscribe(room: HMSRoom, peer: HMSPeer, streamInfo: HMSStreamInfo) {
        peers[streamInfo.streamId] = peer

        client.subscribe(streamInfo, room: room, completion: { [weak self]  (stream, _) in
            DispatchQueue.main.async {
                guard let stream = stream else { return }
                self?.remoteStreams.append(stream)

                guard let videoTrack = stream.videoTracks?.first else { return }
                self?.addVideoTrack(videoTrack)
            }
        })
    }

    func join() {
        client.join(room, completion: { [weak self] (_, _) in
            self?.publish()
        })
    }

    func addVideoTrack(_ track: HMSVideoTrack) {
        videoTracks.append(track)
        collectionView.reloadData()
    }

    func removeVideoTrack(for streamId: String) {
        videoTracks.removeAll { $0.streamId == streamId }
        collectionView.reloadData()
    }

    @IBAction func micMute(_ sender: Any) {
        guard let track = self.localAudioTrack else { return }
        track.enabled = !track.enabled
    }

    @IBAction func videoMute(_ sender: Any) {
        guard let track = self.localVideoTrack else { return }
        track.enabled = !track.enabled

        if !track.enabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.localStream?.videoCapturer?.stopCapture()
            }
        } else {
            localStream?.videoCapturer?.startCapture()
        }
    }

    @IBAction func camSwitch(_ sender: Any) {
        guard let capturer = self.videoCapturer else { return }
        capturer.switchCamera()
    }

    func cleanup() {
        guard let client = client else {
            return
        }

        videoCapturer?.stopCapture()

        client.leave(room)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            client.disconnect()
        }
    }

    func fetchToken(completion: @escaping (String?) -> Void) {
        guard let endpointUrl = URL(string: endpointURL) else {
            completion(nil)
            return
        }

        guard let subDomain = endpointUrl.host?.components(separatedBy: ".").first else {
            completion(nil)
            return
        }

        let parameters = ["room_id": roomName,
                          "user_name": userName,
                          "role": "guest",
                          "env": subDomain
        ]

        // create the url with URL
        guard let url = URL(string: tokenServerURL) else {
            completion(nil)
            return
        }

        // create the session object
        let session = URLSession.shared

        // now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // set http method as POST

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
            completion(nil)
            return
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in

            guard error == nil else {
                print("\(String(describing: error))")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                // create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let token = json["token"] as? String {
                        completion(token)
                    } else {
                        completion(nil)
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }

    // MARK: - Action Handlers

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MeetingViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoTracks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as? VideoCollectionViewCell, indexPath.item < videoTracks.count else {
            return UICollectionViewCell()
        }
        let track = videoTracks[indexPath.item]

        cell.videoView.setVideoTrack(track)

        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        var size = CGSize.zero
//
//        let divider = CGFloat(min(videoTracks.count, 6))
//
//        size.width = collectionView.frame.size.width / divider
//        size.height = collectionView.frame.size.height / divider
//
//        return size
//    }
}

extension MeetingViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let paddingSpace = sectionInsets.left * 3
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / 2

    return CGSize(width: widthPerItem, height: widthPerItem)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return sectionInsets
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return sectionInsets.left
  }
}
