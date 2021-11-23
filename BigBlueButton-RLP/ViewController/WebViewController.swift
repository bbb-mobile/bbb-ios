import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    
    // MARK: Properties
    
    var webView: WKWebView!
        
    // MARK: Views Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebsite()
    }
    
    override func loadView() {
        setupWebView()
    }
    
    // MARK: - Setup WKWebView
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        /// Inject JavaScript which sends message to App
        let userScript = WKUserScript(source: Constants.jsEventListener, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        /// Add ScriptMessageHandler
        contentController.add(self, name: Constants.messageName)
        webConfiguration.userContentController = contentController
        webConfiguration.preferences.javaScriptEnabled = true

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        /// Add custom UserAgent
        webView.customUserAgent = Constants.userAgent
        view = webView
    }
    
    private func loadWebsite() {
        guard let baseURL = BBBURL.baseURL else { return }
        webView.load(URLRequest(url: baseURL))
    }
    
    private func runJavascript() {
        /// Fire event to execute javascript
        webView.evaluateJavaScript(Constants.fireJSEvent) { (_, error) in
            if error != nil {
                print("⚡️☠️ Error executing injected javascript script ☠️⚡️")
            }
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    
    /// This method will be called when the webview navigation fails.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.presentSimpleAlert(title: Constants.failedLoadUrlTitle, message: Constants.failedLoadUrlMessage)
    }
    
    /// Observe webView URL changes
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        let urlString = String(describing: navigationAction.request.url)
        if urlString.contains(Constants.sessionToken) {
            /// Joined the room and connected to BBB server.
            runJavascript()
        }
    }
}

extension WebViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.messageName {
            guard let body = message.body as? [String: Any] else {
                print("Could not convert message body to dictionary: \(message.body)")
                return
            }
            guard let payload = body["payload"] as? String else {
                print("Could not locate payload param in callback request")
                return
            }
            
            print(payload)
        }
    }
}

