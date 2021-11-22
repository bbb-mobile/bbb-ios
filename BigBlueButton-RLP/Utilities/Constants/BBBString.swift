import Foundation

/// Struct that presents the Strings used by the App.
struct BBBString {
  
    private init() {}
    
    ///Title for the error when web page could not be loaded.
    static let failedLoadUrlTitle = "Web page could not be loaded."
    ///Message for the error when web page could not be loaded.
    static let failedLoadUrlMessage = "Please make sure that you are connected to the Internet."
    
    /// WKWebView
    static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15"
    static let sessionToken = "sessionToken"
    static let jsFile = "javascriptSnippet"
    static let jsSnippet =
    """
    const { default: currentUser } = require('/imports/ui/services/auth');
    const { default: { _collection: voiceUserCollection } } = require('/imports/api/voice-users');
    const { meetingID, userID, fullname } = currentUser;
    const { voiceConf } = voiceUserCollection.findOne({ intId: userID });
    const websocketUrl = `wss://${document.location.host}/bbb-webrtc-sfu?sessionToken=${currentUser.sessionToken}`;
    console.log ( "data", {
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
    }
    } );
    """
}
