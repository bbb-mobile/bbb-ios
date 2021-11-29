//
//  SocketMessage.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 26.11.21..
//

import Foundation

/// Model of the socket message to be sent to server when audio connection is established
struct InitialSocketMessage: Codable {
    
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
         voiceBridge: String = "",
         caleeName: String = "",
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
