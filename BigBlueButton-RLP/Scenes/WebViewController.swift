import UIKit
import WebKit
import ReplayKit

class WebViewController: UIViewController, WKUIDelegate {
    
    // MARK: Properties
    private let webNavigationView = WebNavigationView(frame: .zero)
    private var webView: WKWebView!
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()
    private let defaults = UserDefaults.init(suiteName: Constants.appGroup)
    private var broadcastPicker: RPSystemBroadcastPickerView?
    
    private var isPayloadReceived = false
    private var hasSessionToken = false
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Views Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupWebNavigationView()
        layout()
        loadWebsite()
        // TO DO: Trigger broadcastPickerView with webhook, and not here
        showBroadcastPicker()
    }
    
    private func layout() {
        let views: [UIView] = [webView, webNavigationView]
        for subView in views {
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }
        
        NSLayoutConstraint.activate([
            webNavigationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webNavigationView.heightAnchor.constraint(equalToConstant: 50),
            webNavigationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webNavigationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webNavigationView.topAnchor)
        ])
    }
    
    // MARK: - Setup WKWebView
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        // Inject JavaScript which sends message to App
        let getMeetingRoomPayloadScript = WKUserScript(source: Script.meetingRoomPayloadListener,
                                                       injectionTime: .atDocumentEnd,
                                                       forMainFrameOnly: false)
        contentController.addUserScript(getMeetingRoomPayloadScript)
        let muteButtonScript = WKUserScript(source: Script.muteButtonListener,
                                            injectionTime: .atDocumentEnd,
                                            forMainFrameOnly: false)
        contentController.addUserScript(muteButtonScript)
        // Add ScriptMessageHandler
        contentController.add(self, name: Script.meetingRoomMessage)
        contentController.add(self, name: Script.muteButtonMessage)
        webConfiguration.userContentController = contentController
        webConfiguration.preferences.javaScriptEnabled = true

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        // Add custom UserAgent
        webView.customUserAgent = Constants.userAgent
        webView.addObserver(self, forKeyPath: WKWebView.canGoForwardKey, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: WKWebView.canGoBackKey, options: .new, context: nil)
    }
    
    private func setupWebNavigationView() {
        webNavigationView.webNavigationDelegate = self
        webNavigationView.update(canGoBack: webView.canGoBack, canGoForward: webView.canGoForward)
    }
    
    private func loadWebsite() {
        guard let baseURL = BBBURL.baseUrl else { return }
        webView.load(URLRequest(url: baseURL))
    }
    
    private func runJavascript(_ script: String) {
        // Fire event to execute javascript
        webView.evaluateJavaScript(script) { (_, error) in
            if error != nil {
                print("⚡️☠️ Error executing injected javascript script ☠️⚡️")
            }
        }
    }
    
    private func saveSessionCookie() {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            for cookie in cookies {
                if cookie.name == Constants.jsessionId && cookie.isSecure {
                    self?.defaults?.set(cookie.value, forKey: Constants.jsessionId)
                }
            }
        }
    }
    
    // MARK: - Setup Broadcast picker view
    
    private func showBroadcastPicker() {
        /* NOTE: This is against Apple UX policy.
         App may be rejected for showing pickerView without its default button tap */
        let pickerFrame = CGRect(x: 100, y: 100, width: 80, height: 80)
        broadcastPicker = RPSystemBroadcastPickerView(frame: pickerFrame)
        broadcastPicker?.preferredExtension = "com.zuehlke.bbb.BBBBroadcast"
        view.addSubview(broadcastPicker!)
        // Hack for triggering pickerView without showing its default button
        //        for view in broadcastPicker!.subviews {
        //            if let button = view as? UIButton {
        //                button.sendActions(for: .allEvents)
        //            }
        //        }
    }
    
    // Needed because didStartProvisionalNavigation and decidePolicyForNavigationAction don't fire if only part of the webpage is reloaded
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == WKWebView.canGoBackKey ||
                keyPath == WKWebView.canGoForwardKey else { return }
        didUpdate(url: webView.url)
    }

    private func didUpdate(url: URL?) {
        webNavigationView.update(canGoBack: webView.canGoBack, canGoForward: webView.canGoForward)
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
            // Joined the room and connected to BBB server.
            guard !hasSessionToken else { return }
            runJavascript(Script.meetingRoomPayloadListener)
            saveSessionCookie()
            hasSessionToken = true
        }
    }
}

// MARK: - WKScriptMessageHandler Delegate Methods

extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageBody = message.body as? [String: Any] else { return }
        switch message.name {
        case Script.muteButtonMessage:
            print(messageBody)
            
        case Script.meetingRoomMessage:
            guard !isPayloadReceived else { return }
            let payload = Data((messageBody["payload"] as? String)!.utf8)
            do {
                let jsData = try decoder.decode(JavascriptData.self, from: payload)
                isPayloadReceived = true
                if let encodedData = try? encoder.encode(jsData) {
                    defaults?.set(encodedData, forKey: Constants.javascriptData)
                }
            } catch (let error) {
                print("⚡️☠️ Failed to load payload data: \(error.localizedDescription)")
            }
            
        default: return
        }
    }
}

// MARK: BBBWebViewDelegate

extension WebViewController: BBBWebViewDelegate {
    /// Opens a web page in webview
    /// - Parameter url: The url to open.
    func didOpen(url: URL) {
        webView.load(URLRequest(url: url))
    }
}

extension WebViewController: WebNavigationViewDelegate {
    func didTapBackBtn() {
        webView.goBack()
    }
    
    func didTapForwardBtn() {
        webView.goForward()
    }
    
    func didTapRefreshBtn() {
        webView.reload()
    }
}
