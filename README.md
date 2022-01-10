# BBB-iOS
Extending BBB ios mobile application to support screen sharing.

## Requirements
1. Xcode 12.1 or later
2. iOS 13 or later


## Setup and run instructions
1. In order to test and use the application you must register a user on BBB platform using web page 
    (test): https://bbbtest.zdv.uni-mainz.de/b/
    (production): https://bbb-schulen.rlp.net/b/
2. Build and run application on device or on a simulator.
3. Enter previously created user credentials to sign in and you should be redirected to host web page.
4. Start the meeting, allow microphone and camera usage.
5. NOTE: Notice there is a grey recording button in a top left corner - it is just temporary button until final implementation is done with BBB developers.
6. Click on a grey recording button and Broadcast Upload Extension will start, offering to start recording for BBB app. Click Start Recording.
7. BBBBroadcast is the name of Broadcast Upload Extension which is receiving video frames and audio samples in its class SampleHandler. 
8. Audio/Video samples are sent to BBB server through WebRTC.


## Flow
* When app is run and active, WebViewController will load BBB web page and user must sign in.
* As a meeting host you create a meeting, allow microphone and camera usage.
* Now everything functions through webView and you can use it as it is.
* If you want to start screen sharing - click on the grey recording button in top left corner.
* NOTE: The grey recording button will be removed and BBB screen share button will be available in webView.
* We use javascript injection to obtain data from webView loaded page and observe event of tapping on screen share button (when it becomes available).
* When screen sharing is tapped, Broadcast Upload Extension will offer screen recording and will start its flow.
* First websocket connection is made with BBB server in order to exchange and set WebRTC SDP offer and answer, as well as ICE candidates.
* Then everything is handled from SampleHandler class of Broadcast Upload Extension.
* WebRTCClient is a wrapper for WebRTC library and is main engine for sending audio/video samples to BBB server.


## WebRTC:
WebRTC is an open-source project (libjingle_peerConnection) maintained by google with high-level API implementations for both iOS and Android. 
WebRTC API can be read from [here](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API).
WebRTC Framework used in project has been built from [here](https://github.com/stasel/WebRTC)


## References:
* WebRTC website: https://webrtc.org/
* WebRTC source code: https://webrtc.googlesource.com/src
* WebRTC iOS compile guide: https://webrtc.github.io/webrtc-org/native-code/ios/
* appear.in dev blog post: https://github.com/appearin/tech.appear.in/blob/master/source/_posts/Getting-started-with-WebRTC-on-iOS.md (it uses old WebRTC API but still very informative)
* AppRTC: More detailed app to demonstrate WebRTC: https://webrtc.googlesource.com/src/+/refs/heads/master/examples/objc/AppRTCMobile/
* Useful information from pexip: https://pexip.github.io/pexkit-sdk/ios_media
* [Video Chat using WebRTC and Firestore](https://medium.com/@quangtqag/video-chat-using-webrtc-and-firestore-a925de6f89f4) by [Quang](https://github.com/quangtqag)


## Credits:
* WebRTC demo iOS app used as a guiding example: https://github.com/stasel/WebRTC-iOS
