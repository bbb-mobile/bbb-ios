//
//  SdpAnswer.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 29.11.21..
//

import Foundation

struct SdpAnswer: Codable {
    
    let id: String
    let type: String
    let response: String
    var sdpAnswer: String
}
