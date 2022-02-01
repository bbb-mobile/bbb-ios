//
//  WebsocketData.swift
//  Broadcaster
//
//  Created by Milan Bojic on 1.2.22..
//

import Foundation

public protocol WebsocketSdpMessage {}

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
}
