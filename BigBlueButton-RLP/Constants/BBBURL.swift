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
}
