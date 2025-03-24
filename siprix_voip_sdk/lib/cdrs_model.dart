import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calls_model.dart';

/// CDR = CallDetailRecord model (contains attributes of recent call, serializes them to/from json)
class CdrModel extends ChangeNotifier {
  CdrModel.fromCall(this.myCallId, this.accUri, this.remoteExt, this.incoming, this.hasVideo);
  CdrModel();
  static final _fmt = DateFormat('MMM dd, HH:mm a');
  
  /// Id if the CallModel, generated this record
  int myCallId=0;
  
  /// Display name (Contact name if resolved)
  String displName="";
  /// Phone number(extension) of remote side
  String remoteExt="";
  /// Account URI
  String accUri="";
  
  /// Duration of the call
  String duration="";
  /// Has call video
  bool hasVideo = false;
  /// Was call incoming
  bool incoming = false;
  /// Was call connected
  bool connected = false;
  /// Time when call has been initiated
  String madeAtDate = _fmt.format(DateTime.now());
  /// Status code assigned when call ended
  int statusCode=0;

 ///Store model to json string
  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = {
      'accUri' : accUri,
      'remoteExt': remoteExt,
      'displName': displName,
      'statusCode' : statusCode,
      'incoming' : incoming,
      'connected': connected,
      'duration': duration,
      'madeAt': madeAtDate,
      'hasVideo': hasVideo
    };
    return ret;
  }

  /// Creates instance of CdrModel with values read from json
  factory CdrModel.fromJson(Map<String, dynamic> jsonMap) {
    CdrModel cdr = CdrModel();
    jsonMap.forEach((key, value) {
      if((key == 'accUri')&&(value is String))     { cdr.accUri    = value; } else
      if((key == 'remoteExt')&&(value is String))  { cdr.remoteExt = value; } else
      if((key == 'displName')&&(value is String))  { cdr.displName = value; } else
      if((key == 'statusCode')&&(value is int))    { cdr.statusCode= value; } else
      if((key == 'incoming')&&(value is bool))     { cdr.incoming  = value; } else
      if((key == 'connected')&&(value is bool))    { cdr.connected = value; } else
      if((key == 'duration')&&(value is String))   { cdr.duration  = value; } else
      if((key == 'madeAt')&&(value is String))     { cdr.madeAtDate= value; }
    });
    return cdr;
  }

}//CdrModel


/// Model invokes this callback when has changes which should be saved by the app
typedef SaveChangesCallback = void Function(String jsonStr);

/// CDRs list model (contains list of recent calls, methods for managing them)
class CdrsModel extends ChangeNotifier {
  final List<CdrModel> _cdrItems = [];
  static const int kMaxItems=10;

  /// Returns true when list of recent calls is empty
  bool get isEmpty => _cdrItems.isEmpty;
  /// Returns number of recent calls in list
  int get length => _cdrItems.length;
  /// Returns recent call by its index in list
  CdrModel operator [](int i) => _cdrItems[i];

  /// Callback which model invokes when recent calls changes should be saved
  SaveChangesCallback? onSaveChanges;

  /// Add new recent call item based on specified CallModel
  void add(CallModel c) {
    CdrModel cdr = CdrModel.fromCall(c.myCallId, c.accUri, c.remoteExt, c.isIncoming, c.hasVideo);
    _cdrItems.insert(0, cdr);

    if(_cdrItems.length > kMaxItems) {
      _cdrItems.removeLast();
    }
    notifyListeners();
  }

  /// Set 'connected' and other attributes of the recent call item specified by callId
  void setConnected(int callId, String from, String to, bool hasVideo) {
    int index = _cdrItems.indexWhere((c) => c.myCallId==callId);
    if(index == -1) return;

    CdrModel cdr = _cdrItems[index];
    cdr.hasVideo = hasVideo;
    cdr.connected = true;
    notifyListeners();
  }

  /// Set 'terminated' and other attributes of the recent call item specified by callId
  void setTerminated(int callId, int statusCode, String displName, String duration) {
    int index = _cdrItems.indexWhere((c) => c.myCallId==callId);
    if(index == -1) return;
    
    CdrModel cdr = _cdrItems[index];
    cdr.displName = displName;
    cdr.statusCode = statusCode;
    cdr.duration = duration;
    
    notifyListeners();

    _raiseSaveChanges();
  }

  /// Remote recent call item by its index in the list
  void remove(int index) {
    if((index>=0)&&(index < length)) {
      _cdrItems.removeAt(index);
      notifyListeners();
    }
  }

  /// Load list of recent calls from json string
  bool loadFromJson(String cdrsJsonStr) {
    try {
      if(cdrsJsonStr.isEmpty) return false;
      
      _cdrItems.clear();

      final List<dynamic> parsedList = jsonDecode(cdrsJsonStr);
      for (var parsedCdr in parsedList) {
        _cdrItems.add(CdrModel.fromJson(parsedCdr));
      }
      
      notifyListeners();

      return parsedList.isNotEmpty;
    }catch (e) {      
      return false;
    }
  }

  void _raiseSaveChanges() {    
    if(onSaveChanges != null) {
      Future.delayed(Duration.zero, () {
          onSaveChanges?.call(storeToJson());
      });
    }
  }

  /// Store list of recent calls to json string
  String storeToJson() {
    return jsonEncode(_cdrItems);
  }

}//CdrsModel

