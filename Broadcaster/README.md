# Broadcaster

Package which containts WebRTC library and logic to support screen sharing with Broadcast Upload Extension.

## Usage instructions

1. Broadcaster class takes websocketUrl, jsessionId and WebsocketData in its constructor in order to start the WebRTC process.
2. You must provide and conform model type from the main app to WebsocketData protocol in order to provide Broadcaster class with the data which is used to send WebRTC SDP offer message to server and start negotiating process.
3. Check README.md file in the main project folder for further explanation.
