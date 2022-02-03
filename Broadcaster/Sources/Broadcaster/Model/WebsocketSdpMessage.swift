//
//  WebsocketData.swift
//  Broadcaster
//
//  Created by Milan Bojic on 1.2.22..
//

import Foundation

public protocol WebsocketSdpMessage {
    var callerName: String { get }
    var bitrate: Int { get }
    var hasAudio: Bool { get }
    var id: String { get }
    var internalMeetingId: String { get }
    var role: String { get }
    var sdpOffer: String { get }
    var type: String { get }
    var userName: String { get }
    var voiceBridge: String { get }
    
}

struct SdpMessage: Codable, WebsocketSdpMessage {
    let callerName: String
    let bitrate: Int
    let hasAudio: Bool
    let id: String
    let internalMeetingId: String
    let role: String
    var sdpOffer: String
    let type: String
    let userName: String
    let voiceBridge: String
    
    init(_ message: WebsocketSdpMessage) {
        self.callerName = message.callerName
        self.bitrate = message.bitrate
        self.hasAudio = message.hasAudio
        self.id = message.id
        self.internalMeetingId = message.internalMeetingId
        self.role = message.role
        self.sdpOffer = message.sdpOffer
        self.type = message.type
        self.userName = message.userName
        self.voiceBridge = message.voiceBridge
    }
}
