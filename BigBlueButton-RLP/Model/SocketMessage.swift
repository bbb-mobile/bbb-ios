//
//  SocketMessage.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 26.11.21..
//

import Foundation

/// Model which parse data returned from executed javascript snippet
struct Payload: Codable {
    let payload: PayloadData
}

struct PayloadData: Codable {
    let websocketUrl: String
    let payload: ConnectionData
}

struct ConnectionData: Codable {
    
    let callerName: String
    let bitrate: Int
    let hasAudio: Bool
    let id: String
    let internalMeetingId: String
    let role: String
    let sdpOffer: String?
    let type: String
    let userName: String
    let voiceBridge: String
}

/// Model of the socket message to be sent to server when connection is established
struct SocketMessage: Codable {
    
    let id: String
    let type: String
    let role: String
    let internalMeetingId: String
    let voiceBridge: String
    let caleeName: String
    let userId: String
    let userName: String
    let mediaServer: String
    
    init(id: String = "start",
         type: String = "audio",
         role: String = "recv",
         internalMeetingId: String = "",
         voiceBridge: String = "23538",
         caleeName: String = "GLOBAL_AUDIO_23538",
         userId: String = "",
         userName: String = "",
         mediaServer: String = "mediasoup") {
        self.id = id
        self.type = type
        self.role = role
        self.internalMeetingId = internalMeetingId
        self.voiceBridge = voiceBridge
        self.caleeName = caleeName
        self.userId = userId
        self.userName = userName
        self.mediaServer = mediaServer
    }
}
