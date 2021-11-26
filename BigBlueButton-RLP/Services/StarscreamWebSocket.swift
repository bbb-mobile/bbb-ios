//
//  StarscreamWebSocket.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 26.11.21..
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {

    var delegate: WebSocketProviderDelegate?
    private let socket: WebSocket
    var isConnected = false
    
    init(url: URL) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
    
    func send(string: String) {
        socket.write(string: string)
    }
    
    func handleError(_ error: Error?) {
        // TODO: - Implement this method
    }
}

extension StarscreamWebSocket: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            self.delegate?.webSocketDidConnect(self)
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            self.delegate?.webSocketDidDisconnect(self)
        case .text(let string):
            print("Received text: \(string)")
            // TO DO: sdp answer is received here. Send it to delegate method to set it.
        case .binary(let data):
            print("Received data: \(data.count)")
            self.delegate?.webSocket(self, didReceiveData: data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
}
