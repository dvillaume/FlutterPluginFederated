import 'dart:io';

import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';

/// Helper class used to keep different ids of the same call
class CallMatcher {
  ///Id assigned by CallKit when push notification received
  String callkit_CallUUID;

  ///Some data received in push payload (put by remote SIP server)
  ///This field is using to identify/match push and SIP calls
  /// each aplication may use its own way
  String push_Hint;

  ///Id assigned by library when SIP INVITE received
  int sip_CallId;

  CallMatcher(this.callkit_CallUUID, this.push_Hint, [this.sip_CallId = 0]);
}

/// Calls list model (contains app level code of managing calls)
/// Copy this class into own app and redesign as you need
class AppCallsModel extends CallsModel {
  AppCallsModel(IAccountsModel accounts, [this._logs, CdrsModel? cdrs])
      : super(accounts, _logs, cdrs);

  final ILogsModel? _logs;
  final List<CallMatcher> _callMatchers = []; //iOS PushKit specific impl

  /// Handle iOS Pushkit notification received by library (parse payload, update CallKit window, store data from push payload)
  @override
  void onIncomingPush(
      String callkit_CallUUID, Map<String, dynamic> pushPayload) {
    _logs?.print(
        'onIncomingPush callkit_CallUUID:$callkit_CallUUID $pushPayload');
    //Get data from 'pushPayload', which contains app specific details
    Map<String, dynamic>? apsPayload;
    try {
      apsPayload = Map<String, dynamic>.from(pushPayload["aps"]);
    } catch (err) {
      _logs?.print('onIncomingPush get payload err: $err');
    }

    String pushHint = apsPayload?["pushHint"] ?? "pushHint";
    String genericHandle = apsPayload?["callerNumber"] ?? "genericHandle";
    String localizedCallerName = apsPayload?["callerName"] ?? "callerName";
    bool withVideo = apsPayload?["withVideo"] ?? false;

    _callMatchers.add(CallMatcher(callkit_CallUUID, pushHint));

    //Update CallKit
    SiprixVoipSdk().updateCallKitCallDetails(
        callkit_CallUUID, null, localizedCallerName, genericHandle, withVideo);
  }

  @override
  void onIncomingSip(int callId, int accId, bool withVideo, String hdrFrom,
      String hdrTo) async {
    super.onIncomingSip(callId, accId, withVideo, hdrFrom, hdrTo);

    if (Platform.isIOS) {
      //TODO Match push and sip calls using just received SIP INVITE and data from push (put to '_callMatchers')
      //Get some hint from just received SIP INVITE (added by remote server) or math this SIP-call with CallKit-call
      String? pushHintHeaderVal =
          await SiprixVoipSdk().getSipHeader(callId, "X-PushHint");
      _logs?.print('onIncomingSip got pushHint:$pushHintHeaderVal');

      int index =
          _callMatchers.indexWhere((c) => c.push_Hint == pushHintHeaderVal);
      if (index != -1) {
        _logs?.print(
            'onIncomingSip match call:${_callMatchers[index].callkit_CallUUID} <=> $callId');

        //Update CallKit with 'callId'
        _callMatchers[index].sip_CallId = callId;
        SiprixVoipSdk().updateCallKitCallDetails(
            _callMatchers[index].callkit_CallUUID, callId, null, null, null);
      }
    }
  }

  @override
  void onTerminated(int callId, int statusCode) {
    super.onTerminated(callId, statusCode);

    if (Platform.isIOS) {
      int index = _callMatchers.indexWhere((c) => c.sip_CallId == callId);
      if (index != -1) {
        _logs?.print(
            'onTerminated removed call:${_callMatchers[index].callkit_CallUUID}');
        _callMatchers.removeAt(index);
      }
    }
  }
}
