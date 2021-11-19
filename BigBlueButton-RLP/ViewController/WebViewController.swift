import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: Views Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    // MARK: - Setup WKWebView
    
    private func setupWebView() {
        guard let baseURL = BBBURL.baseURL else { return }
        webView.navigationDelegate = self
        webView.load(URLRequest(url: baseURL))
        webView.allowsBackForwardNavigationGestures = true
        /// Add UserAgent
        webView.customUserAgent = BBBString.userAgent
    }
}

extension WebViewController: WKNavigationDelegate {
    
    /// This method will be called when the webview navigation fails.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.presentSimpleAlert(title: BBBString.failedLoadUrlTitle, message: BBBString.failedLoadUrlMessage)
    }
    
    /// Observe webView URL changes
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        let urlString = String(describing: navigationAction.request.url)
        if urlString.contains(BBBString.sessionToken) {
            /// Joined the room and connected to BBB server. Show the ShareScren button
            print("JOINED THE ROOM")
        }
    }
}

