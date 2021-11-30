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
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
    func signalClient(_ signalClient: SignalingClient, didReceiveSocketMessage message: String)
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
    
    func sendInitialSocketMessage(_ message: JavascriptData.Payload) {
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        } catch (let error) {
            debugPrint("Warning: Could not encode socket message: \(error)")
        }
    }
    
    func sendOffer(_ sdpOffer: SdpOffer) {
        do {
            let dataMessage = try self.encoder.encode(sdpOffer)
            self.webSocket.send(data: dataMessage)
        } catch (let error) {
            debugPrint("Warning: Could not encode socket message: \(error)")
        }
    }
    
//    func send(sdp rtcSdp: RTCSessionDescription) {
//        let message = Message.sdp(SessionDescription(from: rtcSdp))
//        do {
//            let dataMessage = try self.encoder.encode(message)
//            let jsonString = String(data: dataMessage, encoding: .utf8)!
//            print("JSON: \(jsonString)")
//            self.webSocket.send(data: dataMessage)
//        }
//        catch {
//            debugPrint("Warning: Could not encode sdp: \(error)")
//        }
//    }
//
//    func send(candidate rtcIceCandidate: RTCIceCandidate) {
//        let message = Message.candidate(IceCandidate(from: rtcIceCandidate))
//        do {
//            let dataMessage = try self.encoder.encode(message)
//            self.webSocket.send(data: dataMessage)
//        }
//        catch {
//            debugPrint("Warning: Could not encode candidate: \(error)")
//        }
//    }
}


extension SignalingClient: WebSocketProviderDelegate {
    
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveSocketMessage message: String) {
        self.delegate?.signalClient(self, didReceiveSocketMessage: message)
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        print("RECEIVED DATA FROM SOCKET, NEED TO PARSE IT")
//        let message: Message
//        do {
//            message = try self.decoder.decode(Message.self, from: data)
//        }
//        catch {
//            debugPrint("Warning: Could not decode incoming message: \(error)")
//            return
//        }
//
//        switch message {
//        case .candidate(let iceCandidate):
//            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
//        case .sdp(let sessionDescription):
//            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
//        }

    }
}
