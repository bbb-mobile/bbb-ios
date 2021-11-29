//
//  JavascriptPayload.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 29.11.21..
//

import Foundation

/// Model which parse data returned from executed javascript snippet
struct JavascriptData: Codable {
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
    var sdpOffer: String?
    let type: String
    let userName: String
    let voiceBridge: String
}
