## 1.0.12
- iOS: Redesigned and improved CallKit+PushKit implementation

## 1.0.11
- Added ability to send and receive text messages (SIP MESSAGE request)
- Added ability to override DisplayName in outgoing call (method 'Dest_SetDisplayName')
- Added ability to handle received MediaControlEvent 'picture_fast_update'
- Fixed bug in 'RewriteContactIp' option implementation when TCP/TLS transport is using
- Fixed parsing RTCP FB parameters of video in SDP
- iOS: Added PushKit support

## 1.0.10
* Fixed closing app caused by SIGPIPE signal

## 1.0.9
* Updated TLS transport implementation (use TLS1.3 by default, ability to use also 1.2 and 1.0)
* Improved ability to detect lost/switched network connections and automatically restore registration
* Added more detailed log output for some cases

## 1.0.8
* Fixed potential crash when app switched between networks and updates registration 

## 1.0.7
* Few more fixes related to handle networks switching and restore registration when app becomes active; 
* Don't unregister account(s) when app stopped by swiping out

## 1.0.6
* Fixed crash when app restored from background

## 1.0.5
* Added ability to re-create transports when app become active after long time in background

## 1.0.4
* Added CallKit support to iOS (library automatically manages it)
* Fixed logs flooding with UDP transport error

## 1.0.3
* Added MinimumOSVersion in plist

## 1.0.2
* Fixed handling case when app adds duplicate subscription.
* Now library raises error 'ESubscrAlreadyExist' and also returns existing subscrId

## 1.0.1
* Fixed podspec file for ios/macos
* Added new ini property 'brandName'
* Enabled ability to make attended transfer when call on hold

## 1.0.0
* Initial release. 
* Contains implementation based on method channels.
