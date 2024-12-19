import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vietmap_automotive_flutter/models/marker.dart';
import 'package:vietmap_automotive_flutter/models/polygon.dart';
import 'package:vietmap_automotive_flutter/models/polyline.dart';

import 'models/events.dart';
import 'vietmap_automotive_flutter_platform_interface.dart';

/// An implementation of [VietmapAutomotiveFlutterPlatform] that uses method channels.
class MethodChannelVietmapAutomotiveFlutter
    extends VietmapAutomotiveFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vietmap_automotive_flutter');

  MethodChannelVietmapAutomotiveFlutter();

  /// Set up the method channel and listen for method calls from the native platform.
  @override
  void init({
    void Function()? onMapReady,
    void Function(double latitude, double longitude)? onMapClick,
    void Function()? onMapRendered,
    void Function()? onStyleLoaded,
  }) {
    /// Set the method call handler to listen for method calls from the native platform.
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case Events.onMapClick:
          final latitude = call.arguments['lat'] as double;
          final longitude = call.arguments['lng'] as double;
          onMapClick?.call(latitude, longitude);
          break;
        case Events.onMapReady:
          onMapReady?.call();
          break;
        case Events.onMapRendered:
          onMapRendered?.call();
          break;
        case Events.onStyleLoaded:
          onStyleLoaded?.call();
          break;
        default:
          debugPrint('Method not implemented');
      }
    });
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>(Events.getPlatformVersion);
    return version;
  }

  /// Initialize the map with the given style URL and VietMap API key.
  @override
  Future<String?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) async {
    final responseMessage =
        await methodChannel.invokeMethod<String>(Events.initAutomotive, {
      'styleUrl': styleUrl,
      'vietMapAPIKey': vietMapAPIKey,
    });
    return responseMessage;
  }

  /// Add the given markers to the map.
  /// The markers must have a valid image path.
  /// The image will be loaded from the asset and converted to base64 before sending to the native platform.
  /// Width and height of each marker must be both provided or both null
  @override
  Future<List<Marker>> addMarkers({required List<Marker> markers}) async {
    final markersJson = <Map<String, dynamic>>[];
    await Future.forEach(
      markers,
      (Marker m) async {
        try {
          final bytesData = await rootBundle.load(m.imagePath);
          final imageBytes = bytesData.buffer.asUint8List();
          final base64Image = base64Encode(imageBytes);

          final markerJson = m.toJson();
          markerJson['base64Encoded'] = base64Image;

          markersJson.add(markerJson);
        } catch (e) {
          debugPrint(e.toString());
        }
      },
    );

    final responseMarkersJson = await methodChannel.invokeListMethod<int>(
      Events.addMarkers,
      markersJson,
    );

    /// If the response is not empty, set the markerId for each marker.
    if (responseMarkersJson?.isNotEmpty ?? false) {
      for (var i = 0; i < markers.length; i++) {
        markers[i].markerId = responseMarkersJson![i];
      }
      return markers;
    } else {
      return [];
    }
  }

  /// Remove the markers with the given markerIds from the map.
  @override
  Future<bool?> removeMarker({required List<int> markerIds}) async {
    return await methodChannel.invokeMethod<bool>(
      Events.removeMarker,
      {
        'markerIds': markerIds,
      },
    );
  }

  /// Remove all markers from the map.
  @override
  Future<bool?> removeAllMarkers() async {
    return await methodChannel.invokeMethod<bool>(Events.removeAllMarkers);
  }

  /// Add the given polylines to the map.
  /// Each polyline must have at least two points.
  @override
  Future<List<Polyline>> addPolylines(
      {required List<Polyline> polylines}) async {
    final polylinesJson = polylines.map((e) => e.toJson()).toList();
    final resp = await methodChannel.invokeListMethod<int>(
      Events.addPolylines,
      {
        'polylines': polylinesJson,
      },
    );

    /// If the response is not empty, set the polylineId for each polyline.
    if (resp?.isNotEmpty ?? false) {
      for (var i = 0; i < polylines.length; i++) {
        polylines[i].id = resp![i];
      }
      return polylines;
    } else {
      return [];
    }
  }

  /// Remove the polylines with the given polylineIds from the map.
  @override
  Future<bool?> removePolyline({required List<int> polylineIds}) async {
    return await methodChannel.invokeMethod<bool>(
      Events.removePolyline,
      {
        'polylineIds': polylineIds,
      },
    );
  }

  /// Remove all polylines from the map.
  @override
  Future<bool?> removeAllPolylines() async {
    return await methodChannel.invokeMethod<bool>(Events.removeAllPolylines);
  }

  /// Add the given polygons to the map.
  /// Each polygon must have at least three points.
  @override
  Future<List<Polygon>> addPolygons({required List<Polygon> polygons}) async {
    final polygonsJson = polygons.map((e) => e.toJson()).toList();
    final resp = await methodChannel.invokeListMethod<int>(
      Events.addPolygons,
      {
        'polygons': polygonsJson,
      },
    );

    if (resp?.isNotEmpty ?? false) {
      for (var i = 0; i < polygons.length; i++) {
        polygons[i].id = resp![i];
      }
      return polygons;
    } else {
      return [];
    }
  }

  /// Remove the polygons with the given polygonIds from the map.
  @override
  Future<bool?> removePolygon({required List<int> polygonIds}) async {
    return await methodChannel.invokeMethod<bool>(
      Events.removePolygon,
      {
        'polygonIds': polygonIds,
      },
    );
  }

  /// Remove all polygons from the map.
  @override
  Future<bool?> removeAllPolygons() async {
    return await methodChannel.invokeMethod<bool>(
      Events.removeAllPolygons,
    );
  }
}
