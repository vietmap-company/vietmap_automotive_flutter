import 'package:vietmap_automotive_flutter/models/marker.dart';
import 'package:vietmap_automotive_flutter/models/polyline.dart';

import 'models/polygon.dart';
import 'vietmap_automotive_flutter_platform_interface.dart';

class VietmapAutomotiveFlutter {
  final VietmapAutomotiveFlutterPlatform _vietmapAutomotiveFlutterPlatform =
      VietmapAutomotiveFlutterPlatform.instance;

  final void Function()? onMapReady;
  final void Function(
    double latitude,
    double longitude,
  )? onMapClick;
  final void Function()? onMapRendered;
  final void Function()? onStyleLoaded;

  VietmapAutomotiveFlutter({
    this.onMapReady,
    this.onMapClick,
    this.onMapRendered,
    this.onStyleLoaded,
  });

  Future<String?> getPlatformVersion() {
    return _vietmapAutomotiveFlutterPlatform.getPlatformVersion();
  }

  Future<String?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) async {
    return await _vietmapAutomotiveFlutterPlatform.initAutomotive(
        styleUrl: styleUrl, vietMapAPIKey: vietMapAPIKey);
  }

  Future<List<Marker>> addMarkers({
    required List<Marker> markers,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.addMarkers(markers: markers);
  }

  Future<bool?> removeMarker({required List<int> markerIds}) async {
    return await _vietmapAutomotiveFlutterPlatform.removeMarker(
        markerIds: markerIds);
  }

  Future<bool?> removeAllMarkers() async {
    return await _vietmapAutomotiveFlutterPlatform.removeAllMarkers();
  }

  Future<List<Polyline>> addPolylines({
    required List<Polyline> polylines,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.addPolylines(
        polylines: polylines);
  }

  Future<bool?> removePolyline({required List<int> polylineIds}) async {
    return await _vietmapAutomotiveFlutterPlatform.removePolyline(
        polylineIds: polylineIds);
  }

  Future<bool?> removeAllPolylines() async {
    return await _vietmapAutomotiveFlutterPlatform.removeAllPolylines();
  }

  Future<List<Polygon>> addPolygons({
    required List<Polygon> polygons,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.addPolygons(
        polygons: polygons);
  }

  Future<bool?> removePolygon({required List<int> polygonIds}) async {
    return await _vietmapAutomotiveFlutterPlatform.removePolygon(
        polygonIds: polygonIds);
  }

  Future<bool?> removeAllPolygons() async {
    return await _vietmapAutomotiveFlutterPlatform.removeAllPolygons();
  }

  void init() {
    _vietmapAutomotiveFlutterPlatform.init(
      onMapReady: onMapReady,
      onMapClick: onMapClick,
      onMapRendered: onMapRendered,
      onStyleLoaded: onStyleLoaded,
    );
  }
}
