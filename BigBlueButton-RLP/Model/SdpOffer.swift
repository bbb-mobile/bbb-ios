//
//  SdpOffer.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 29.11.21..
//

import Foundation

struct SdpOffer: Codable {
    
    let id: String
    let type: String
    let role: String
    let voiceBridge: String
    var sdpOffer: String
    
    init(from data: JavascriptData.Payload) {
        self.id = "subscriberAnswer"
        self.type = data.type
        self.role = data.role
        self.sdpOffer = ""
        self.voiceBridge = data.voiceBridge
    }
}
