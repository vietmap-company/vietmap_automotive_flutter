import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vietmap_automotive_flutter_method_channel.dart';

abstract class VietmapAutomotiveFlutterPlatform extends PlatformInterface {
  /// Constructs a VietmapAutomotiveFlutterPlatform.
  VietmapAutomotiveFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static VietmapAutomotiveFlutterPlatform _instance = MethodChannelVietmapAutomotiveFlutter();

  /// The default instance of [VietmapAutomotiveFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelVietmapAutomotiveFlutter].
  static VietmapAutomotiveFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VietmapAutomotiveFlutterPlatform] when
  /// they register themselves.
  static set instance(VietmapAutomotiveFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
