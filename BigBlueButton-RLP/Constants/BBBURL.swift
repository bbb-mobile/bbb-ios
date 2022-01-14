import Foundation

/// Enum that presents the URLs used by the App.
enum BBBURL {
    
    static var baseUrl: URL? {
        return AppEnvironment.isDebugMode ?
        // Debug
        URL(string: "https://droplet-1146.meetbbb.com") :
        // Release
        URL(string: "https://bbb-schulen.rlp.net/b/")
    }
    
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
