## 1.0.13
- Android: Updated SiprixRinger implementation
- Android: Redesigned plugin with ability to work in background isolate and handle push notif
- Updated example app with Firebase push notification related functionality

## 1.0.12
- iOS: Redesigned and improved CallKit+PushKit implementation
- Updated example app with PushKit related functionality

## 1.0.11
- Added ability to send and receive text messages (SIP MESSAGE request)
- Added ability to override DisplayName in outgoing call (method 'Dest_SetDisplayName')
- Added ability to handle received MediaControlEvent 'picture_fast_update'
- Fixed bug in 'RewriteContactIp' option implementation when TCP/TLS transport is using
- Fixed parsing RTCP FB parameters of video in SDP
- Android: added ability to switch camera by invoke 'setVideoDevice(0)'
- Android: updated permissions request functionality
- iOS: Added PushKit support

## 1.0.10
* iOS: Fixed closing app caused by SIGPIPE signal
* Android: Send callIncoming/accept events to the app only after sync accounts
* Android: Restored foreground service permissions in example app manifest 
  (plugin doesn't add them by default)
* Added more arguments to the method 'CallsModel::sendDtmf'

## 1.0.9
* iOS: Updated TLS transport implementation (use TLS1.3 by default, ability to use also 1.2 and 1.0)
* iOS: Improved ability to detect transports lose/switch and automatically restore registration
* iOS: Added more detailed log output for some cases
* iOS: Added CallKit icon
* Android: Removed foreground service permissions

## 1.0.8
* Android, iOS: Fixed potential crash when app switched between networks and updates registration 
* Generate random port number on plugin level when adding new account

## 1.0.7
* Android: Added ability to handle AirPlaneMode ON/OFF; Fixes related to handle networks switching; 
* iOS: Fixes related to handle networks switching and restore registration when app becomes active; 

## 1.0.6
* iOS: Fixed crash when app restored from background

## 1.0.5
* iOS: Added ability to re-create transports when app become active after long time in background
* Fixed wrong argument of method 'updateAccount' in 'platform_interface'

## 1.0.4
* Added CallKit support to iOS (library automatically manages it)
* Fixed logs flooding with UDP transport error

## 1.0.3
* Updated iOS lib (added MinimumOSVersion in plist)

## 1.0.2
* Fixed handling case when app adds duplicate subscription.
* Now library raises error 'ESubscrAlreadyExist' and also returns existing subscrId

## 1.0.1
* Fixed podspec file for ios/macos
* Added documentation comments
* Added new ini property 'brandName'
* Enabled ability to make attended transfer when call on hold

## 1.0.0
* Initial release. 
* Includes SiprixSDK in binary form for 5 platforms and ready to use models for easy UI development.
