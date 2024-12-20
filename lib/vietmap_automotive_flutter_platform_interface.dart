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

  /// Initializes the plugin and sets up the necessary event listeners.
  /// This method should be called when the plugin object is constructed.
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

  /// Initializes the automotive map with the given style URL and VietMap API key.
  /// This method should be called before using any map-interacting methods.
  Future<String?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) {
    throw UnimplementedError('initAutomotive() has not been implemented.');
  }

  /// Adds list of markers to the Android Auto and Apple CarPlay map surface.
  /// Returns a list of markers that have been added to the map.
  Future<List<Marker>> addMarkers({required List<Marker> markers}) {
    throw UnimplementedError('addMarkers() has not been implemented.');
  }

  /// Removes markers by selected [markerIds] from the Android Auto and Apple CarPlay map surface.
  /// Returns a boolean value indicating whether the markers have been removed successfully.
  Future<bool?> removeMarker({required List<int> markerIds}) {
    throw UnimplementedError('removeMarker() has not been implemented.');
  }

  /// Removes all markers from the Android Auto and Apple CarPlay map surface.
  /// Returns a boolean value indicating whether the markers have been removed successfully.
  Future<bool?> removeAllMarkers() {
    throw UnimplementedError('removeAllMarkers() has not been implemented.');
  }

  /// Adds list of polylines to the Android Auto and Apple CarPlay map surface.
  /// Returns a list of polylines that have been added to the map.
  Future<List<Polyline>> addPolylines({required List<Polyline> polylines}) {
    throw UnimplementedError('addPolylines() has not been implemented.');
  }

  /// Removes polylines by selected [polylineIds] from the Android Auto and Apple CarPlay map surface.
  /// Returns a boolean value indicating whether the polylines have been removed successfully.
  Future<bool?> removePolyline({required List<int> polylineIds}) {
    throw UnimplementedError('removePolyline() has not been implemented.');
  }

  /// Removes all polylines from the Android Auto and Apple CarPlay map surface.
  /// Returns a boolean value indicating whether the polylines have been removed successfully.
  Future<bool?> removeAllPolylines() {
    throw UnimplementedError('removeAllPolylines() has not been implemented.');
  }

  /// Adds list of polygons to the Android Auto and Apple CarPlay map surface.
  /// Returns a list of polygons that have been added to the map.
  Future<List<Polygon>> addPolygons({required List<Polygon> polygons}) {
    throw UnimplementedError('addPolygons() has not been implemented.');
  }

  /// Removes polygons by selected [polygonIds] from the Android Auto and Apple CarPlay map surface.
  /// Returns a boolean value indicating whether the polygons have been removed successfully.
  Future<bool?> removePolygon({required List<int> polygonIds}) {
    throw UnimplementedError('removePolygon() has not been implemented.');
  }

  /// Removes all polygons from the Android Auto and Apple CarPlay map surface.
  /// Returns a boolean value indicating whether the polygons have been removed successfully.
  Future<bool?> removeAllPolygons() {
    throw UnimplementedError('removeAllPolygons() has not been implemented.');
  }
}
