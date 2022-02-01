//
//  RemoteIceCandidate.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 2.12.21..
//

import Foundation
import WebRTC

// This struct represent IceCandidate received from remote server
struct RemoteIceCandidate: Codable {
    let type: String
    let id: String
    let candidate: IceCandidate
    
    var rtcIceCandidate: RTCIceCandidate {
        return candidate.rtcIceCandidate
    }
}
