import 'package:vietmap_automotive_flutter/models/marker.dart';
import 'package:vietmap_automotive_flutter/models/polyline.dart';

import 'models/polygon.dart';
import 'vietmap_automotive_flutter_platform_interface.dart';

class VietmapAutomotiveFlutter {
  Future<String?> getPlatformVersion() {
    return VietmapAutomotiveFlutterPlatform.instance.getPlatformVersion();
  }

  Future<String?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) {
    return VietmapAutomotiveFlutterPlatform.instance
        .initAutomotive(styleUrl: styleUrl, vietMapAPIKey: vietMapAPIKey);
  }

  Future<List<Marker>> addMarkers({
    required List<Marker> markers,
  }) async {
    return await VietmapAutomotiveFlutterPlatform.instance
        .addMarkers(markers: markers);
  }

  Future<bool?> removeMarker({required List<int> markerIds}) async {
    return await VietmapAutomotiveFlutterPlatform.instance
        .removeMarker(markerIds: markerIds);
  }

  Future<bool?> removeAllMarkers() async {
    return await VietmapAutomotiveFlutterPlatform.instance.removeAllMarkers();
  }

  Future<List<Polyline>> addPolylines({
    required List<Polyline> polylines,
  }) async {
    return await VietmapAutomotiveFlutterPlatform.instance
        .addPolylines(polylines: polylines);
  }

  Future<bool?> removePolyline({required List<int> polylineIds}) async {
    return await VietmapAutomotiveFlutterPlatform.instance
        .removePolyline(polylineIds: polylineIds);
  }

  Future<bool?> removeAllPolylines() async {
    return await VietmapAutomotiveFlutterPlatform.instance.removeAllPolylines();
  }

  Future<List<Polygon>> addPolygons({
    required List<Polygon> polygons,
  }) async {
    return await VietmapAutomotiveFlutterPlatform.instance
        .addPolygons(polygons: polygons);
  }

  Future<bool?> removePolygon({required List<int> polygonIds}) async {
    return await VietmapAutomotiveFlutterPlatform.instance
        .removePolygon(polygonIds: polygonIds);
  }

  Future<bool?> removeAllPolygons() async {
    return await VietmapAutomotiveFlutterPlatform.instance.removeAllPolygons();
  }
}
