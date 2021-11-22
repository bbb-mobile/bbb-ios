import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var shareScreenButton: UIButton!
        
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
    
    // MARK: IBActions
    @IBAction func shareScreen(_ sender: UIButton) {
        do {
            let jsFileUrl = Bundle.main.url(forResource: BBBString.jsFile, withExtension: "js")!
            let jsText = try String(contentsOf: jsFileUrl)
            print(jsText)
            webView.evaluateJavaScript(jsText) { (result, error) in
                print("RESULT: \(String(describing: result))")
                print("ERROR: \(String(describing: error))")
                
                
                //                    let script = WKUserScript(source: jsText,
                //                                              injectionTime: .atDocumentEnd,
                //                                              forMainFrameOnly: false)
                //
                //                    webView.configuration.userContentController.add(self, name: "callbackHandler")
                //                    webView.configuration.userContentController.addUserScript(script)
            }
        } catch(let error) {
            print(error.localizedDescription)
        }
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
            /// Joined the room and connected to BBB server.
            shareScreenButton.isHidden = false
        }
    }
}

//extension WebViewController: WKScriptMessageHandler {
//
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if message.name == "callbackHandler" {
//            guard let body = message.body as? [String: Any] else {
//                print("could not convert message body to dictionary: \(message.body)")
//                return
//            }
//
//            guard let payload = body["payload"] as? String else {
//                print("Could not locate payload param in callback request")
//                return
//            }
//
//            print(payload)
//        }
//    }
//}

