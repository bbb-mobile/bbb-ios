import UIKit

/// Protocol representing the behavior of a delegate for opening a URL.
protocol BBBWebViewDelegate: AnyObject {
    
    /// Opens a web page in webview
    /// - Parameter url: The url to open.
    func didOpen(url: URL)
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var webViewDelegate: BBBWebViewDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let webViewController = WebViewController()
        webViewDelegate = webViewController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = webViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else { return false }
        
        webViewDelegate?.didOpen(url: incomingURL)
        return true
    }
}

