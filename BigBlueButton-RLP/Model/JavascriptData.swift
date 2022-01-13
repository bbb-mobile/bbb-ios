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
    var payload: Payload
    
    /// Payload received after javascript snippet executed
    struct Payload: Codable {
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
        
        private enum CodingKeys: String, CodingKey {
            case callerName, bitrate, hasAudio, id, internalMeetingId, role, sdpOffer, type, userName, voiceBridge
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            callerName = try values.decode(String.self, forKey: .callerName)
            bitrate = try values.decode(Int.self, forKey: .bitrate)
            hasAudio = try values.decode(Bool.self, forKey: .hasAudio)
            id = try values.decode(String.self, forKey: .id)
            internalMeetingId = try values.decode(String.self, forKey: .internalMeetingId)
            role = try values.decode(String.self, forKey: .role)
            sdpOffer = try values.decodeIfPresent(String.self, forKey: .sdpOffer) ?? ""
            type = try values.decode(String.self, forKey: .type)
            userName = try values.decode(String.self, forKey: .userName)
            voiceBridge = try values.decode(String.self, forKey: .voiceBridge)
        }
    }
}


