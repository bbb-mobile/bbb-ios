import Foundation

/// Struct that presents the Strings used by the App.
struct Constants {
  
    private init() {}
    
    // Title for the error when web page could not be loaded.
    static let failedLoadUrlTitle = "Web page could not be loaded."
    
    // Message for the error when web page could not be loaded.
    static let failedLoadUrlMessage = "Please make sure that you are connected to the Internet."
    
    // WKWebView
    static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15"
    static let sessionToken = "sessionToken"
    static let eventName = "message" /// Important: do not change event name!
    static let messageName = "iosListener"
    static let jsEventListener =
                """
                window.addEventListener('\(eventName)', function(e) {
                    const { default: currentUser } = require('/imports/ui/services/auth');
                    const { default: { _collection: voiceUserCollection } } = require('/imports/api/voice-users');
                    const { meetingID, userID, fullname } = currentUser;
                    const { default: { _collection: meetings } } = require('/imports/api/meetings');
                    const voiceConf = meetings.find({}).fetch()[0].voiceProp.voiceConf;
                    const websocketUrl = `wss://${document.location.host}/bbb-webrtc-sfu?sessionToken=${currentUser.sessionToken}`;
                    const data = JSON.stringify({
                                    websocketUrl,
                                    payload: {
                                    callerName: userID,
                                    bitrate: 1500,
                                    hasAudio: false,
                                    id: "start",
                                    internalMeetingId: meetingID,
                                    role: "send",
                                    sdpOffer: null,
                                    type: "screenshare",
                                    userName: fullname,
                                    voiceBridge: voiceConf
                                    }});
                window.webkit.messageHandlers.\(messageName).postMessage({'payload': data}) });
                """
    static let fireJSEvent = "document.dispatchEvent(new Event('\(eventName)'));"

    // WebRTC
    static let sdpAnswer = "sdpAnswer"
    static let iceCandidate = "iceCandidate"
}
