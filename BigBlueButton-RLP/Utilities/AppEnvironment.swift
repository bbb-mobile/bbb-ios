import Foundation

/// Struct that represent the app environment.
struct AppEnvironment {
    
    private init () {}
    
    /// checks if the app runs in debug mode
    static var isDebugMode: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
}
