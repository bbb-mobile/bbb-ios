//
//  Script.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 20.12.21..
//

import Foundation

enum Script {
        
    // Meeting room listener
    static let meetingRoomMessage = "meetingRoomPayloadReceived"
    static let meetingRoomPayloadListener =
                """
                window.addEventListener('message', function(e) {
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
                                    voiceBridge: voiceConf,
                                    mediaServer: "kurento"
                                    }});
                window.webkit.messageHandlers.\(meetingRoomMessage).postMessage({'payload': data}) });
                """
    
    // Screen share button script
    static let screenShareMessage = "screenShareMessage"
    static let screenShareButton =
                """
                setInterval( () => {
                const existing_start_sharing_button = [...document.querySelectorAll('[data-test="startScreenShare"]')].filter(element => !element.getAttribute("data-bbbnative"))[0];
                if(existing_start_sharing_button) {
                const new_start_sharing_button = existing_start_sharing_button.cloneNode(true);
                new_start_sharing_button.setAttribute("data-bbbnative", true);
                new_start_sharing_button.onclick = function(e) {
                alert("This is a replacement function");
                e.preventDefault();
                };
                existing_start_sharing_button.parentNode.replaceChild(new_start_sharing_button, existing_start_sharing_button);
                }
                }, 500);
                """
    
    
    // Mute button listener
    /* NOTE: Mute button is visible only if microphone audio is enabled.
             Need to get exact event from BBB when microphone is enabled in order to evaluate/register muteButtonListener script.
             Mute button ID is dinamically changed and cannot be used.
             Class name is used in listener script but is too long and strange.
             Conclusion: Adding javascript listener for mute button states is not the best approach.
    */
    /* TO DO: Decide what is the best way to observe the microphone audio enable/disable events in webView BBB html client.
              Propose to receive microphone enabled/disabled events via websocket because we need to regulate
              webRTC audio transfer state in Broadcast Upload Extension where socket and webRTC are instantiated.
    */
    static let muteButtonMessage = "muteButtonMessage"
    static let muteButtonListener =
                """
                document.getElementsByClassName('lg--Q7ufB buttonWrapper--x8uow muteToggle--LY4Tr')[0].addEventListener('click', (event) => {
                    event.stopPropagation();
                    window.webkit.messageHandlers.\(muteButtonMessage).postMessage({'status': 'ok'});
                });
                """
}
