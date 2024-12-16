import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vietmap_automotive_flutter/models/polyline.dart';

import 'models/marker.dart';
import 'models/polygon.dart';
import 'vietmap_automotive_flutter_method_channel.dart';

abstract class VietmapAutomotiveFlutterPlatform extends PlatformInterface {
  /// Constructs a VietmapAutomotiveFlutterPlatform.
  VietmapAutomotiveFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static VietmapAutomotiveFlutterPlatform _instance =
      MethodChannelVietmapAutomotiveFlutter();

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

  void init({
    void Function()? onMapReady,
    void Function(double latitude, double longitude)? onMapClick,
    void Function()? onMapRendered,
    void Function()? onStyleLoaded,
  }) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) {
    throw UnimplementedError('initAutomotive() has not been implemented.');
  }

  Future<List<Marker>> addMarkers({required List<Marker> markers}) {
    throw UnimplementedError('addMarkers() has not been implemented.');
  }

  Future<bool?> removeMarker({required List<int> markerIds}) {
    throw UnimplementedError('removeMarker() has not been implemented.');
  }

  Future<bool?> removeAllMarkers() {
    throw UnimplementedError('removeAllMarkers() has not been implemented.');
  }

  Future<List<Polyline>> addPolylines({required List<Polyline> polylines}) {
    throw UnimplementedError('addPolylines() has not been implemented.');
  }

  Future<bool?> removePolyline({required List<int> polylineIds}) {
    throw UnimplementedError('removePolyline() has not been implemented.');
  }

  Future<bool?> removeAllPolylines() {
    throw UnimplementedError('removeAllPolylines() has not been implemented.');
  }

  Future<List<Polygon>> addPolygons({required List<Polygon> polygons}) {
    throw UnimplementedError('addPolygons() has not been implemented.');
  }

  Future<bool?> removePolygon({required List<int> polygonIds}) {
    throw UnimplementedError('removePolygon() has not been implemented.');
  }

  Future<bool?> removeAllPolygons() {
    throw UnimplementedError('removeAllPolygons() has not been implemented.');
  }
}
