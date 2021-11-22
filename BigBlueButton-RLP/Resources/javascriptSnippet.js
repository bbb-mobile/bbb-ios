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