//
//  Script.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 20.12.21..
//

import Foundation

struct Script {
    
    static let eventName = "message" /// Important: do not change event name because it is window event type!
    static let fireJSEvent = "document.dispatchEvent(new Event('\(eventName)'));"
    
    // Meeting room listener
    static let meetingRoomMessage = "meetingRoomPayloadReceived"
    static let meetingRoomPayloadListener =
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
                window.webkit.messageHandlers.\(meetingRoomMessage).postMessage({'payload': data}) });
                """
    
    // Mute button listener
    static let muteButtonMessage = "muteButtonMessage"
    static let muteButtonListener =
                """
                var button = document.getElementById('tippy-58');
                if(button != null) {
                    button.addEventListener('click', function(){
                        window.webkit.messageHandlers.\(muteButtonMessage).postMessage('muteButton_clicked');
                    });
                }
                """
}
