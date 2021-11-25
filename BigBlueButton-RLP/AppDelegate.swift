import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = buildWebViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func buildWebViewController() -> WebViewController {
        let webRTCClient = WebRTCClient(iceServers: BBBURL.bbbTurnServers)
        let webViewController = WebViewController(webRTCClient: webRTCClient)
        return webViewController
    }
}

