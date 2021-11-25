import UIKit
import WebKit
import WebRTC

class WebViewController: UIViewController, WKUIDelegate {
    
    // MARK: Properties
    
    private var webView: WKWebView!
    private var signalingClient: SignalingClient?
    private var webRTCClient: WebRTCClient
    
    private var isPayloadReceived = false
    private var hasSesssionToken = false
    
    // MARK: - Initialization
    
    init(webRTCClient: WebRTCClient) {
        self.webRTCClient = webRTCClient
        super.init(nibName: String(describing: WebViewController.self), bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        // Inject JavaScript which sends message to App
        let userScript = WKUserScript(source: Constants.jsEventListener, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        // Add ScriptMessageHandler
        contentController.add(self, name: Constants.messageName)
        webConfiguration.userContentController = contentController
        webConfiguration.preferences.javaScriptEnabled = true

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        // Add custom UserAgent
        webView.customUserAgent = Constants.userAgent
        view = webView
    }
    
    private func loadWebsite() {
        guard let baseURL = BBBURL.baseURL else { return }
        webView.load(URLRequest(url: baseURL))
    }
    
    private func runJavascript() {
        // Fire event to execute javascript
        webView.evaluateJavaScript(Constants.fireJSEvent) { (_, error) in
            if error != nil {
                print("⚡️☠️ Error executing injected javascript script ☠️⚡️")
            }
        }
    }
    
    // MARK: - WebRTC
    
    private func sendSDPOffer() {
        webRTCClient.offer { [weak self] (sdp) in
            self?.signalingClient?.send(sdp: sdp)
            print("Sent sdp offer: \(sdp)")
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    
    // This method will be called when the webview navigation fails.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.presentSimpleAlert(title: Constants.failedLoadUrlTitle, message: Constants.failedLoadUrlMessage)
    }
    
    // Observe webView URL changes
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        let urlString = String(describing: navigationAction.request.url)
        if urlString.contains(Constants.sessionToken) {
            // Joined the room and connected to BBB server.
            if !hasSesssionToken {
                runJavascript()
                hasSesssionToken = true
            }
        }
    }
}

// MARK: - WKScriptMessageHandler Delegate Methods

extension WebViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if !isPayloadReceived {
            if message.name == Constants.messageName {
                guard let body = message.body as? [String: Any] else {
                    print("Could not convert message body to dictionary: \(message.body)")
                    return
                }
                guard let payload = body["payload"] as? String else {
                    print("Could not locate payload param in callback request")
                    return
                }
                
                // Create JSON data from payload and parse it
                isPayloadReceived = true
                let jsonData = Data(payload.utf8)
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        // Connect to websocket
                        if let websocketUrlString = json["websocketUrl"] as? String {
                            guard let websocketUrl = URL(string: websocketUrlString) else { return }
                            let websocketProvider: WebSocketProvider = NativeWebSocket(url: websocketUrl)
                            signalingClient = SignalingClient(webSocket: websocketProvider)
                            signalingClient?.delegate = self
                            signalingClient?.connect()
                        } else {
                            print("Could not parse websocket URL")
                        }
                    }
                } catch (let error) {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - SignalClientDelegate Delegate Methods

extension WebViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        // Send local SDP to server
        sendSDPOffer()
        print("Websocket connected")
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("Websocket disconnected")
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        // Set remote SDP
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient.set(remoteCandidate: candidate) { error in
            print("Received remote candidate")
        }
    }
}

// MARK: - WebRTCClient Delegate Methods

extension WebViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("Discovered local candidate")
        signalingClient?.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        print(state)
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
