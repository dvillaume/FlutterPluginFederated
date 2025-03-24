## 1.0.7
- Updated SiprixRinger implementation (don't set audioManager mode; modified vibraror)

## 1.0.6
- Added ability to send and receive text messages (SIP MESSAGE request)
- Added ability to override DisplayName in outgoing call (method 'Dest_SetDisplayName')
- Added ability to handle received MediaControlEvent 'picture_fast_update'
- Fixed bug in 'RewriteContactIp' option implementation when TCP/TLS transport is using
- Fixed parsing RTCP FB parameters of video in SDP
- Android: updated permissions request functionality
- Android: added ability to switch camera by invoke 'setVideoDevice(0)'

## 1.0.5
* Send call incoming/accepts events to the app only after sync accounts
  (happens when activity destroyed, but service continues running and received new call)

## 1.0.4
* Fixed potential crash when app switched between networks 

## 1.0.3
* Added ability to handle AirPlaneMode ON/OFF
* Fixes related to handle networks switching; 

## 1.0.2 * 
* Fixed handling case when app adds duplicate subscription.
* Now library raises error 'ESubscrAlreadyExist' and also returns existing subscrId

## 1.0.1
* Added new ini property 'brandName'
* Enabled ability to make attended transfer when call on hold

## 1.0.0
* Initial release. 
* Contains implementation based on method channels.
