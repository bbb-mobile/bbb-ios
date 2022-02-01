//
//  NativeSocketProvider.swift
//  WebRTC-Demo
//
//  Created by Milan Bojic on 23/11/2021.
//

import Foundation

@available(iOS 13.0, *)
class NativeWebSocket: NSObject, WebSocketProvider {
    
    var delegate: WebSocketProviderDelegate?
    private let url: URL
    private let jsessionId: String
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    init(url: URL, jsessionId: String) {
        self.url = url
        self.jsessionId = jsessionId
        super.init()
    }

    func connect() {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        request.setValue("\(Constants.jsessionId)=\(jsessionId)", forHTTPHeaderField: "Cookie")
        let socket = urlSession.webSocketTask(with: request)
        socket.resume()
        self.socket = socket
        self.listen()
    }

    func send(data: Data) {
        self.socket?.send(.data(data)) { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func send(message: String) {
        self.socket?.send(.string(message)) { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    private func listen() {
        self.socket?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self.delegate?.webSocket(self, didReceiveData: data)
                    self.listen()
                    
                case .string(let text):
                    self.delegate?.webSocket(self, didReceiveSocketMessage: text)
                    self.listen()
                    
                @unknown default:
                    debugPrint("⚡️ Warning: Unknown socket message format received.")
                    self.listen()
                }
                
            case .failure:
                self.disconnect()
            }
        }
    }
    
    private func disconnect() {
        self.socket?.cancel()
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
}

@available(iOS 13.0, *)
extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate  {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.disconnect()
    }
}
