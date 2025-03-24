import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'siprix_voip_sdk.dart';


/// Contains video frame attributes provided by native plugins
class RTCVideoValue {
  const RTCVideoValue({
    this.width = 0.0,
    this.height = 0.0,
    this.rotation = 0,
    this.hasTexture = false,
  });
  
  ///Width of the video frame
  final double width;
  ///Height of the video frame
  final double height;
  final int rotation;
  final bool hasTexture;

  static const RTCVideoValue empty = RTCVideoValue();

  double get aspectRatio {
    if (width == 0.0 || height == 0.0) {
      return 1.0;
    }
    return (rotation == 90 || rotation == 270)
        ? height / width
        : width / height;
  }

  RTCVideoValue copyWith({
    double? width, double? height,
    int? rotation, bool hasTexture = true,
  }) {
    return RTCVideoValue(
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      hasTexture: this.width != 0 && this.height != 0 && hasTexture,
    );
  }

  @override
  String toString() =>
      '$runtimeType(width: $width, height: $height, rotation: $rotation)';
}



/// SiprixVideoRenderer - holds texture, created by native plugins, and listening video frame events raised by native plugins
class SiprixVideoRenderer extends ValueNotifier<RTCVideoValue> {
  SiprixVideoRenderer() : super(RTCVideoValue.empty);
  StreamSubscription<dynamic>? _eventSubscription;  
  /// Invalid texture id constant
  static const int kInvalidTextureId = -1;
  /// Invalid call id constant
  static const int kInvalidCallId = -1;
  int _textureId = kInvalidTextureId;
  late final ILogsModel? _logs;

  /// Width of the received video frame
  int get videoWidth => value.width.toInt();
  /// Height of the received video frame
  int get videoHeight => value.height.toInt();
  /// AspectRatio of the received video frame
  double get aspectRatio => value.aspectRatio;
  
  /// TextureId created for rendering
  int  get textureId => _textureId;
  /// Is created texture
  bool get hasTexture=> _textureId != kInvalidTextureId;
  
  /// Frame resize handler
  Function? onResize;

  /// Create texture id rendering video of the specifed call
  Future<void> init(int srcCallId, [ILogsModel? logs]) async {
    if (_textureId != kInvalidTextureId) return;
    _logs = logs;

    try{
      _textureId = await SiprixVoipSdk().videoRendererCreate() ?? 0;
    } on PlatformException catch (err) {
      _logs?.print('Cant create renderer Err: ${err.code} ${err.message}');     
    }
        
    if(_textureId != kInvalidTextureId) {
      _logs?.print('Created textureId: $textureId');
      _eventSubscription = EventChannel('Siprix/Texture$textureId')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);

        setSourceCall(srcCallId);
    }
  }

  /// Use created texture for rendering video of specified call
  void setSourceCall(int callId) async {
    if(callId==kInvalidCallId) return;

    try{
      await SiprixVoipSdk().videoRendererSetSourceCall(_textureId, callId);
    } on PlatformException catch (err) {
      _logs?.print('Cant set src call for renderer Err: ${err.code} ${err.message}');
    }
  }

  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    if (_textureId != kInvalidTextureId) {
      await SiprixVoipSdk().videoRendererDispose(_textureId);
      _logs?.print('Disposed texture: $_textureId');
      _textureId = 0;
    }
    return super.dispose();
  }

  /// Handle video frame changes
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'didTextureChangeRotation':
        value = value.copyWith(rotation: map['rotation'], hasTexture: hasTexture);
        onResize?.call();
        break;
      case 'didTextureChangeVideoSize':
        value = value.copyWith(
            width: 0.0 + map['width'],
            height: 0.0 + map['height'],
            hasTexture: hasTexture);
        onResize?.call();
        break;      
    }
  }

  /// Handle video frame errors
  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

}//SiprixVideoRenderer


/// SiprixVideoView - widget which displays specified renderer
class SiprixVideoView extends StatelessWidget {
  /// Constructor
  const SiprixVideoView(this._renderer, {Key? key,}) : super(key: key);

  final SiprixVideoRenderer _renderer;
  
  /// Set texture quality
  final FilterQuality filterQuality = FilterQuality.low; 

  @override
  Widget build(BuildContext context) {
    return _renderer.hasTexture
                    ? AspectRatio(aspectRatio: _renderer.aspectRatio, 
                        child: Texture(textureId: _renderer.textureId, filterQuality: filterQuality))
                    : const Placeholder();
  }
}
