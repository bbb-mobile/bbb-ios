//
//  SampleHandler.swift
//  BBBBroadcast
//
//  Created by Milan Bojic on 6.12.21..
//

import ReplayKit
import VideoToolbox
import Broadcaster

class SampleHandler: RPBroadcastSampleHandler {
    
    private var broadcaster: Broadcaster?
    private let defaults = UserDefaults.init(suiteName: Constants.appGroup)
    private var isWebRTCConnected: Bool = false
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        print("Broadcast has started")
        // Parse data from web browser and start websocket connection
        guard let jsessionId = defaults?.object(forKey: Constants.jsessionId) as? String else { return }
        guard let javascriptData = defaults?.object(forKey: Constants.javascriptData) as? Data else { return }
        do {
            let jsData = try JSONDecoder().decode(JavascriptData.self, from: javascriptData)
            broadcaster = Broadcaster(websocketUrl: jsData.websocketUrl, jsessionId: jsessionId, sdpMessage: jsData.payload)
            broadcaster?.delegate = self
        } catch (let error) {
            print("⚡️☠️ Failed to load payload data: \(error.localizedDescription)")
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        print("Broadcast has paused.")
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        print("Broadcast has resumed.")
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        print("Broadcast has finished.")
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            // Handle video sample buffer
            guard isWebRTCConnected else { break }
            broadcaster?.pushVideo(sampleBuffer)
            break
        case .audioApp:
            // Handle audio sample buffer for app audio
            break
        case .audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}

// MARK: - WebRTCClient Delegate Methods

extension SampleHandler: BroadcasterDelegate {
    
    func broadcaster(_ client: Broadcaster, didChangeConnectionState state: BroadcasterState) {
        switch state {
        case .connected, .completed:
            isWebRTCConnected = true
        case .disconnected:
            isWebRTCConnected = false
        case .failed, .closed:
            isWebRTCConnected = false
        case .new, .checking, .count:
           break
        }
    }
}
