//
//  StarscreamWebSocket.swift
//  BBBBroadcast
//
//  Created by Milan Bojic on 17.12.21..
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {

    var delegate: WebSocketProviderDelegate?
    private let socket: WebSocket
    var isConnected = false
    private let defaults = UserDefaults.init(suiteName: Constants.appGroup)

    init(url: URL) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        // Set cookie obtained from webView in order to authorize socket connection
        let jsessionId = defaults?.object(forKey: Constants.jsessionId) as? String
        request.setValue("\(Constants.jsessionId)=\(jsessionId ?? "")", forHTTPHeaderField: "Cookie")
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
    
    func send(message: String) {
        socket.write(string: message)
    }
    
    func handleError(_ error: Error?) {
        guard let error = error else { return }
        print("⚡️☠️ Error connecting through websocket: \(error.localizedDescription)")
    }
}

extension StarscreamWebSocket: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("Websocket is connected: \(headers)")
            self.delegate?.webSocketDidConnect(self)
        case .disconnected(let reason, let code):
            isConnected = false
            print("Websocket is disconnected: \(reason) with code: \(code)")
            self.delegate?.webSocketDidDisconnect(self)
        case .text(let message):
            print("Received text: \(message)")
            self.delegate?.webSocket(self, didReceiveSocketMessage: message)
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
