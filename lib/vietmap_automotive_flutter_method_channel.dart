import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'vietmap_automotive_flutter_platform_interface.dart';

/// An implementation of [VietmapAutomotiveFlutterPlatform] that uses method channels.
class MethodChannelVietmapAutomotiveFlutter
    extends VietmapAutomotiveFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vietmap_automotive_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) async {
    final responseMessage =
        await methodChannel.invokeMethod<String>('initAutomotive', {
      'styleUrl': styleUrl,
      'vietMapAPIKey': vietMapAPIKey,
    });
    return responseMessage;
  }
}
