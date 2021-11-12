import UIKit
import WebKit

/// ViewController that presents the webview.
class WebViewController: UIViewController {
    
    // MARK: Properties
    
    /// webkit web view
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: Views Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - load views
    
    override func loadView() {
        super.loadView()
        loadWebView()
    }
    
    private func loadWebView() {
        guard let baseURL = BBBURL.baseURL else { return }
        webView.navigationDelegate = self
        webView.load(URLRequest(url: baseURL))
        webView.allowsBackForwardNavigationGestures = true
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.presentSimpleAlert(title: BBBString.failedLoadUrlTitle, message: BBBString.failedLoadUrlMessage)
    }
}

