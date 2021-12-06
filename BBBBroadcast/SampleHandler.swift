//
//  SampleHandler.swift
//  BBBBroadcast
//
//  Created by Milan Bojic on 6.12.21..
//

import ReplayKit
import VideoToolbox

class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        print("Broadcast has started: \(String(describing: setupInfo))")
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
        print("Broadcast sample buffer: \(sampleBuffer)")
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
//            var imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
//            var pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer) as CMTime
//            VTCompressionSessionEncodeFrame(session, imageBuffer: imageBuffer, presentationTimeStamp: pts, duration: kCMTimeInvalid, frameProperties: nil, infoFlagsOut: nil, outputHandler: nil)
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}
