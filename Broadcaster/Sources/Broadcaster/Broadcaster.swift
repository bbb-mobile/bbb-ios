//
//  Broadcaster.swift
//  Broadcaster
//
//  Created by Milan Bojic on 1.2.22..
//

import Foundation
import WebRTC

public protocol BroadcasterDelegate: AnyObject {
    func broadcaster(_ client: Broadcaster, didChangeConnectionState state: BroadcasterState)
}

public enum BroadcasterState {
    case connected, completed, disconnected, failed, closed, new, checking, count
}

public class Broadcaster {

    let websocketUrl: String
    let jsessionId: String
    let sdpMessage: WebsocketSdpMessage
    private var signalingClient: SignalingClient?
    private var webRTCClient = WebRTCClient(iceServers: STUNServers.bbbTurnServers)
    
    public weak var delegate: BroadcasterDelegate?
    
    public init(websocketUrl: String, jsessionId: String, sdpMessage: WebsocketSdpMessage) {
        self.websocketUrl = websocketUrl
        self.jsessionId = jsessionId
        self.sdpMessage = sdpMessage
    }
    
    public func start() {
        guard !websocketUrl.isEmpty && !jsessionId.isEmpty else { return }
        webRTCClient.delegate = self
        setupWebSocketConnection(with: websocketUrl)
    }
    
    public func pushVideo(_ sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timeStampNs: Int64 = Int64(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * 1000000000)
        let rtcPixlBuffer = RTCCVPixelBuffer(pixelBuffer: imageBuffer)
        let rtcVideoFrame = RTCVideoFrame(buffer: rtcPixlBuffer, rotation: ._0, timeStampNs: timeStampNs)
        webRTCClient.push(videoFrame: rtcVideoFrame)
        print("Pushed webRTC video frame")
    }
    
    // MARK: Setup WebSocket

    private func setupWebSocketConnection(with url: String) {
        guard let websocketUrl = URL(string: url) else { return }
        // Use Native socket to establish connection
        let websocketProvider: WebSocketProvider = NativeWebSocket(url: websocketUrl, jsessionId: jsessionId)
        signalingClient = SignalingClient(webSocket: websocketProvider)
        signalingClient?.delegate = self
        signalingClient?.connect()
    }
    
    // MARK: - WebRTC

    private func sendInitialSocketMessageWithSdpOffer() {
        webRTCClient.offer { [weak self] (localSdpOffer) in
            guard let `self` = self else { return }
            var sdp = SdpMessage(self.sdpMessage)
            sdp.sdpOffer = localSdpOffer.sdp
            self.signalingClient?.sendMessageWithSdpOffer(sdp)
            print("✅ Sent socket message with local sdp offer: \(sdp)")
        }
    }
        
    private func setSdpAnswer(_ sdpAnswer: RTCSessionDescription) {
        webRTCClient.set(remoteSdp: sdpAnswer) { (error) in
            if error != nil {
                print("⚡️☠️ Error setting remote sdp answer: \(error!.localizedDescription)")
            } else {
                print("✅ Set remote SDP answer: \(sdpAnswer.sdp)")
            }
        }
    }
    
    private func setRemoteIceCandidate(_ candidate: RTCIceCandidate) {
        webRTCClient.set(remoteCandidate: candidate) { error in
            if error != nil {
                print("⚡️☠️ Error setting remote ice candidate: \(error!.localizedDescription)")
            } else {
                print("✅ Set remote ICECandidate")
            }
        }
    }
}

// MARK: - SignalClientDelegate Delegate Methods

extension Broadcaster: SignalClientDelegate {
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

extension Broadcaster: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        signalingClient?.send(candidate: candidate)
        print("✅ Sent local ICECandidate to server.")
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        switch state {
        case .connected:
            delegate?.broadcaster(self, didChangeConnectionState: .connected)
        case .completed:
            delegate?.broadcaster(self, didChangeConnectionState: .completed)
        case .disconnected:
            delegate?.broadcaster(self, didChangeConnectionState: .disconnected)
        case .failed:
            delegate?.broadcaster(self, didChangeConnectionState: .failed)
        case .closed:
            delegate?.broadcaster(self, didChangeConnectionState: .closed)
        case .new, .checking, .count:
           break
        @unknown default:
            print("Unknown connection state.")
        }
    }
}
