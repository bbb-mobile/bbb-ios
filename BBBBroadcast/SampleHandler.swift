//
//  SampleHandler.swift
//  BBBBroadcast
//
//  Created by Milan Bojic on 6.12.21..
//

import ReplayKit
import VideoToolbox
import WebRTC

class SampleHandler: RPBroadcastSampleHandler {
    
    private var signalingClient: SignalingClient?
    private var webRTCClient = WebRTCClient(iceServers: BBBURL.bbbTurnServers)
    private let defaults = UserDefaults.init(suiteName: Constants.appGroup)
    
    private var javascriptPayload: JavascriptData.Payload?
    private var isConnected: Bool = false
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        print("Broadcast has started")
        // Set webRTC delegate
        webRTCClient.delegate = self
        // Parse data from web browser and start websocket connection
        guard let javascriptData = defaults?.object(forKey: Constants.javascriptData) as? Data else { return }
        do {
            let jsData = try JSONDecoder().decode(JavascriptData.self, from: javascriptData)
            javascriptPayload = jsData.payload
            setupWebSocketConnection(with: jsData.websocketUrl)
        } catch (let error) {
            print("⚡️☠️ Failed to load payload data: \(error.localizedDescription)")
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        print("Broadcast has paused.")
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        print("Broadcast has resumed.")
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        print("Broadcast has finished.")
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            // Handle video sample buffer
            guard isConnected, let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { break }
            let timeStampNs: Int64 = Int64(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * 1000000000)
            let rtcPixlBuffer = RTCCVPixelBuffer(pixelBuffer: imageBuffer)
            let rtcVideoFrame = RTCVideoFrame(buffer: rtcPixlBuffer, rotation: ._0, timeStampNs: timeStampNs)
            webRTCClient.push(videoFrame: rtcVideoFrame)
            print("Pushed webRTC video frame")
            break
        case .audioApp:
            // Handle audio sample buffer for app audio
            break
        case .audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
    
    // MARK: Setup WebSocket

    private func setupWebSocketConnection(with url: String) {
        guard let websocketUrl = URL(string: url) else { return }
        // Use Native socket to establish connection
        let websocketProvider: WebSocketProvider = StarscreamWebSocket(url: websocketUrl)
        signalingClient = SignalingClient(webSocket: websocketProvider)
        signalingClient?.delegate = self
        signalingClient?.connect()
    }
    
    // MARK: - WebRTC

    private func sendInitialSocketMessageWithSdpOffer() {
        webRTCClient.offer { [weak self] (localSdpOffer) in
            guard let `self` = self, var data = self.javascriptPayload else { return }
            data.sdpOffer = localSdpOffer.sdp
            self.signalingClient?.sendMessageWithSdpOffer(data)
            print("✅ Sent socket message with local sdp offer: \(data)")
        }
    }
        
    private func setSdpAnswer(_ sdpAnswer: RTCSessionDescription) {
        webRTCClient.set(remoteSdp: sdpAnswer) { (error) in
            if error != nil {
                print("⚡️☠️ Error setting remote sdp answer: \(error!.localizedDescription)")
            } else {
                print("Set remote SDP answer")
            }
        }
    }
    
    private func setRemoteIceCandidate(_ candidate: RTCIceCandidate) {
        webRTCClient.set(remoteCandidate: candidate) { [weak self] error in
            guard let `self` = self else { return }
            if error != nil {
                print("⚡️☠️ Error setting remote ice candidate: \(error!.localizedDescription)")
            } else {
                print("Set remote ICECandidate")
                self.isConnected = true
            }
        }
    }
}

// MARK: - SignalClientDelegate Delegate Methods

extension SampleHandler: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        sendInitialSocketMessageWithSdpOffer()
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("Websocket disconnected")
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveSdpAnswer sdpAnswer: RTCSessionDescription) {
        setSdpAnswer(sdpAnswer)
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteIceCandidate rtcIceCandidate: RTCIceCandidate) {
        setRemoteIceCandidate(rtcIceCandidate)
    }
}

// MARK: - WebRTCClient Delegate Methods

extension SampleHandler: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        signalingClient?.send(candidate: candidate)
    }
}
