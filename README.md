# v0.8.0  iOS SDK - Getting Started

Here you will find everything you need to build experiences with video using 100ms iOS SDK. Dive into our SDKs, quick starts, add real-time video, voice, and screen sharing to your web and mobile applications.

## Pre requisites

- iOS 10.0+
- Xcode 11+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Brytecam SDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

pod 'HMSVideo', '~> 0.8.0'

## Quick start

Checkout example app at [https://github.com/100mslive/hmsvideo-ios/tree/master/Example](https://github.com/100mslive/hmsvideo-ios/tree/master/Example)

## Concepts

---

- **Room** - A room represents a real-time audio, data, video and/or screenshare session, the basic building block of the Brytecam Video SDK
- **Stream** - A stream represents real-time audio, video and data media streams that are shared to a room
- **Peer/Participant** - A peer represents all participants connected to a room (other than the local participant)
- **Publish** - A local participant can share its audio, video and data tracks by "publishing" its tracks to the room
- **Subscribe** - A local participant can stream any peer's audio, video and data tracks by "subscribing" to their tracks
- **Broadcast** - A local participant can send any message/data to all peers in the room

## Create and instantiate HMSClient (100ms Client)

---

This will instantiate an `HMSClient` object

```swift
//Create an HMSPeer instance for local peer
let peer = HMSPeer(name: userName)
peer.authToken = "Inset your token here"

let config = HMSClientConfig()
//config.endpoint = "Override endpoint URL if needed"

//Create a 100ms video client
client = HMSClient(peer: peer, config: config)
```

Click [here](https://www.notion.so/Token-Generation-42b0f9d078224db4bf934608829a8b53) to see how to generate your token

Use `wss://conf.brytecam.com` as endpoint URL for production and `wss://staging.brytecam.com` as endpoint URL for staging

## Setup listeners

---

After joining, immediately add listeners to listen to peers joining, new streams being added to the room

```swift
client.onPeerJoin = { (room, peer) in
    // Update UI if needed
}

client.onPeerLeave = { (room, peer) in
    // Update UI if needed
}

client.onStreamAdd = { (room, peer, streamInfo)  in
    // Subscribe to the stream if needed
}

client.onStreamRemove = { (room, streamInfo)  in
    // Remove remote stream view if needed
}

client.onBroadcast = { (room, peer, message) in
    // update UI if needed
}

client.onConnect = { 
		// Client connected, this is a good place to call join(room)
}

client.onDisconnect = { error in 
		// Connection lost or could not be established. 
		// Good place to retry or show an error to the user.
}
```

## Connect

---

After instantiating `HMSClient`, connect to 100ms' server

```swift
//The client will connect to the WebSocket channel provided through the config
client.connect
```

## Join a room

---

```swift
//Pass the unique id for the room here as a String
let room = HMSRoom(roomId: roomName)

client.join(room) { (success, error) in
    //check for error and publish a local stream
}
```

Generate a unique `roomid` for each session to avoid conflicts

## Create and Get local camera/mic streams

---

```swift
//You can set codec, bitrate, framerate, etc here.
let constraints = HMSMediaStreamConstraints()
constraints.shouldPublishAudio = true
constraints.shouldPublishVideo = true
constraints.codec = .VP8
constraints.bitrate = 256
constraints.frameRate = 25
constraints.resolution = .QVGA

let localStream = client.getLocalStream(constraints)
```

Please use the following settings for video that looks good in postcard-sized videos - codec:`VP8`, bitrate `256`, framerate `25`. We will extend this in the future to add more options including front/back camera

Apple requires your app to provide static messages to display to the
user when the system asks for camera or microphone permission: 

If your app uses device cameras, include the  NSCameraUsageDescription
key in your app’s Info.plist file.

If your app uses device microphones, include the  NSMicrophoneUsageDescription
key in your app’s Info.plist file.

For each key, provide a message that explains to the user why your app
needs to capture media, so that the user can feel confident granting
permission to your app.

Important

If the appropriate key is not present in your app’s  Info.plist
file when your app requests authorization or attempts to use a capture
device, the system terminates your app.

## Get local media for screen share

---

**This will not be covered by v0.8 SDK. Coming soon.**

## Display local stream

---

```swift
//The following code is a sample.

//Get the video capturer and video track
let videoCapturer = stream.videoCapturer
let localVideoTrack = stream.videoTracks?.first

//Begin capturing video from the camera
videoCapturer?.startCapture()

//Create a view for rendering video track and add to the UI hierarchy
if let track = localVideoTrack {
    let videoView = HMSVideoView()
		videoView.setVideoTrack(track)
		view.addSubview(videoView)
}
```

## Publish

---

A local participant can share her audio, video and data tracks by "publishing" its tracks to the room

```swift
client.publish(localStream, room: room, completion: { (stream, error) in
    //Handle error if any, update UI if needed
})
```

## Subscribe

---

This method "subscribes" to a peer's stream. This should ideally be called in the `onStreamAdd` listener

```swift
client.subscribe(streamInfo, room: room, completion: { (stream, error) in
	//Handle error if any, update UI if needed
})
```

## Broadcast

---

This method broadcasts a payload to all participants

```swift
client.broadcast(message, room: room, completion: { (stream, error) in
	//Handle error if any, update UI if needed
})
```

## Unpublish local stream

---

```swift
client.unpublish(stream, room: room, completion: { (stream, error) in
	//Handle error if any, update UI if needed
})
```

## Unsubscribe to a peer's stream

---

```swift
client.unsubscribe(stream, room: room, completion: { (stream, error) in
	//Handle error if any, update UI if needed
})
```

## Disconnect client

---

```swift
//The client will disconnect from the WebSocket channel provided
client.disconnect();
```