//
//  STUNServers.swift
//  Broadcaster
//
//  Created by Milan Bojic on 1.2.22..
//

import Foundation

enum STUNServers {
    
    /// Bbb stun servers
    static var bbbTurnServers: [String] {
        return ["stun:bbb-turn.zdv.Uni-Mainz.DE",
                "stun:bbb-turn-1u2.zdv.uni-mainz.de",
                "stun:bbb-turn-3u4.zdv.uni-mainz.de"]
    }
    
    /// Google's public stun servers.
    static var defaultIceServers: [String] {
        return ["stun:stun.l.google.com:19302",
                "stun:stun1.l.google.com:19302",
                "stun:stun2.l.google.com:19302",
                "stun:stun3.l.google.com:19302",
                "stun:stun4.l.google.com:19302"]
    }
}
