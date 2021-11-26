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
    private var socketMessageToSend = SocketMessage()
    
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
        setupShareButton()
        
    }
    
    override func loadView() {
        setupWebView()
    }
    
    // MARK: - Mock share screen button
    
    private let shareScreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Button", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.isHidden = true
        button.addTarget(self, action: #selector(shareScreen), for: .touchUpInside)
        return button
    }()
    
    private func setupShareButton() {
        view.addSubview(shareScreenButton)
        NSLayoutConstraint.activate([
            shareScreenButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            shareScreenButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 120),
            shareScreenButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -120),
            shareScreenButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func shareScreen(sender: UIButton!) {
        // Do nothing for now
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
            // TO DO: - Change sdp sending model
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
                guard let messageBody = message.body as? [String: Any] else { return }
                let payload = Data((messageBody["payload"] as? String)!.utf8)
                do {
                    let payloadData = try JSONDecoder().decode(PayloadData.self, from: payload)
                    if payloadData.payload.voiceBridge != "" {
                        isPayloadReceived = true
                        socketMessageToSend = SocketMessage(internalMeetingId: payloadData.payload.internalMeetingId,
                                                            voiceBridge: payloadData.payload.voiceBridge,
                                                            caleeName: "GLOBAL_AUDIO_\(payloadData.payload.voiceBridge)",
                                                            userId: payloadData.payload.callerName,
                                                            userName: payloadData.payload.userName)
                        // Audio connection established, we can send offer to webRTC through websocket
                        let websocketUrlString = payloadData.websocketUrl
                        print("WEBSOCKET URL: \(websocketUrlString)")
                        guard let websocketUrl = URL(string: websocketUrlString) else { return }
                        let websocketProvider: WebSocketProvider = StarscreamWebSocket(url: websocketUrl)
                        signalingClient = SignalingClient(webSocket: websocketProvider)
                        signalingClient?.delegate = self
                        signalingClient?.connect()
                    }
                } catch (let error) {
                    print("Failed to load payload data: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - SignalClientDelegate Delegate Methods

extension WebViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        print("Websocket connected")
        signalClient.sendTestMessage(socketMessageToSend)
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
