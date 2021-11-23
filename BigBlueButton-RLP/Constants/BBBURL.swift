import Foundation

/// Struct that presents the URLs used by the App.
struct BBBURL {
    
    private init() {}
    
    /// Webpage base url
    static let baseURL = AppEnvironment.isDebugMode ?
                         Debug.baseURL : Release.baseURL
    
    /// Websocket server url.
    static let websocketURL: String? = nil
    
    /// Struct that presents the release URLs used by the App.
    private struct Release {
        
        private init() {}
        
        /// Release base url
        static let baseURL = URL(string: "https://bbb-schulen.rlp.net/b/")
    }
    
    /// Struct that presents the debug URLs used by the App.
    private struct Debug {
        
        private init() {}
        
        /// Debug base url.
        static let baseURL = URL(string: "https://bbbtest.zdv.uni-mainz.de/b/")
    }
}
