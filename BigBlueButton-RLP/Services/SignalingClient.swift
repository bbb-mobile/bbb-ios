//
//  SignalClient.swift
//  WebRTC
//
//  Created by Milan Bojic on 23/11/2021.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveSdpAnswer sdpAnswer: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteIceCandidate rtcIceCandidate: RTCIceCandidate)
}

final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    weak var delegate: SignalClientDelegate?
    
    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
    }
    
    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    func sendMessageWithSdpOffer(_ message: JavascriptData.Payload) {
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        } catch (let error) {
            debugPrint("Warning: Could not encode socket message: \(error)")
        }
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        let iceCandidate = IceCandidate(from: rtcIceCandidate)
        do {
            let dataMessage = try self.encoder.encode(iceCandidate)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}

// MARK: WebsocketProviderDelegate Methods

extension SignalingClient: WebSocketProviderDelegate {
    
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveSocketMessage message: String) {
        let webRtcData = Data(message.utf8)
        if message.contains(Constants.sdpAnswer) {
            // Remote sdpAnswer received
            do {
                let webRtcAnswer = try decoder.decode(SdpAnswer.self, from: webRtcData)
                let sdpAnswer = RTCSessionDescription(type: .answer, sdp: webRtcAnswer.sdpAnswer)
                delegate?.signalClient(self, didReceiveSdpAnswer: sdpAnswer)
            } catch (let error) {
                print("⚡️☠️ Failed to load sdpAnswer: \(error.localizedDescription)")
            }
        } else if message.contains(Constants.iceCandidate) {
            // Remote iceCandidate received
            do {
                let remoteIceCandidate = try decoder.decode(RemoteIceCandidate.self, from: webRtcData)
                delegate?.signalClient(self, didReceiveRemoteIceCandidate: remoteIceCandidate.rtcIceCandidate)
            } catch (let error) {
                print("⚡️☠️ Failed to load remoteIceCandidate: \(error.localizedDescription)")
            }
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        print("Received data from the socket.")
    }
}
