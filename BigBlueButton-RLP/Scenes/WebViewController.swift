import UIKit
import WebKit
import WebRTC

class WebViewController: UIViewController, WKUIDelegate {
    
    // MARK: Properties
    
    private var webView: WKWebView!
    private var signalingClient: SignalingClient?
    private var webRTCClient: WebRTCClient
    private var decoder = JSONDecoder()
    
    private var isPayloadReceived = false
    private var hasSessionToken = false
    private var javascriptPayload: JavascriptData.Payload?
    
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
        // Set webRTC delegate
        webRTCClient.delegate = self
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
        guard let baseURL = BBBURL.baseUrl else { return }
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
    
    // MARK: Setup WebSocket
    
    private func setupWebSocketConnection(with url: String) {
        guard let websocketUrl = URL(string: url) else { return }
        // Use Starscream socket library to establish connection
        let websocketProvider: WebSocketProvider = StarscreamWebSocket(url: websocketUrl)
        signalingClient = SignalingClient(webSocket: websocketProvider)
        signalingClient?.delegate = self
        signalingClient?.connect()
    }
    
    // MARK: - WebRTC
    
    private func sendInitialSocketMessageWithSdpOffer() {
        webRTCClient.offer { [weak self] (localSdpOffer) in
            guard let `self` = self, var data = self.javascriptPayload else { return }
            data.sdpOffer = localSdpOffer.sdp
            self.signalingClient?.sendMessageWithSdpOffer(data)
            print("✅ Sent socket message with local sdp offer: \(data)")
        }
    }
        
    private func setSdpAnswer(_ sdpAnswer: RTCSessionDescription) {
        webRTCClient.set(remoteSdp: sdpAnswer) { (error) in
            if error != nil {
                print("⚡️☠️ Error setting remote sdp answer: \(error!.localizedDescription)")
            }
        }
    }
    
    private func setRemoteIceCandidate(_ candidate: RTCIceCandidate) {
        webRTCClient.set(remoteCandidate: candidate) { error in
            if error != nil {
                print("⚡️☠️ Error setting remote ice candidate: \(error!.localizedDescription)")
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
            // Joined the room and connected to BBB server.
            guard !hasSessionToken else { return }
            runJavascript()
            hasSessionToken = true
        }
    }
}

// MARK: - WKScriptMessageHandler Delegate Methods

extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard !isPayloadReceived else { return }
        guard message.name == Constants.messageName else { return }
        guard let messageBody = message.body as? [String: Any] else { return }
        let payload = Data((messageBody["payload"] as? String)!.utf8)
        do {
            let jsData = try decoder.decode(JavascriptData.self, from: payload)
            isPayloadReceived = true
            javascriptPayload = jsData.payload
            setupWebSocketConnection(with: jsData.websocketUrl)
        } catch (let error) {
            print("⚡️☠️ Failed to load payload data: \(error.localizedDescription)")
        }
    }
}

// MARK: - SignalClientDelegate Delegate Methods

extension WebViewController: SignalClientDelegate {
    
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        sendInitialSocketMessageWithSdpOffer()
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("Websocket disconnected")
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveSdpAnswer sdpAnswer: RTCSessionDescription) {
        setSdpAnswer(sdpAnswer)
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteIceCandidate rtcIceCandidate: RTCIceCandidate) {
        setRemoteIceCandidate(rtcIceCandidate)
    }
}

// MARK: - WebRTCClient Delegate Methods

extension WebViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        signalingClient?.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        print("Received data through webRTC")
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
