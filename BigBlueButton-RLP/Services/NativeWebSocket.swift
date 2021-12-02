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
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    init(url: URL) {
        self.url = url
        super.init()
    }

    func connect() {
        let socket = urlSession.webSocketTask(with: url)
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
        self.socket?.receive { [weak self] message in
            guard let self = self else { return }
            
            switch message {
            case .success(.data(let data)):
                self.delegate?.webSocket(self, didReceiveData: data)
                self.listen()
                
            case .success(.string(let message)):
                self.delegate?.webSocket(self, didReceiveSocketMessage: message)
                self.listen()
                
            case .success:
                debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
                self.listen()

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
