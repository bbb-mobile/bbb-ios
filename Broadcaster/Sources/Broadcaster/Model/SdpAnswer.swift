//
//  SdpAnswer.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 29.11.21..
//

import Foundation
import WebRTC

struct SdpAnswer: Codable {
    
    let id: String
    let type: String
    let role: String
    let response: String
    var sdpAnswer: String
    
    var rtcSdpAnswer: RTCSessionDescription {
        return RTCSessionDescription(type: .answer, sdp: sdpAnswer)
    }
}
