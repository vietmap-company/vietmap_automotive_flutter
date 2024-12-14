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

  @override
  void init({
    void Function()? onMapReady,
    void Function(double latitude, double longitude)? onMapClick,
    void Function()? onMapRendered,
    void Function()? onStyleLoaded,
  }) {
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

    if (responseMarkersJson?.isNotEmpty ?? false) {
      for (var i = 0; i < markers.length; i++) {
        markers[i].markerId = responseMarkersJson![i];
      }
      return markers;
    } else {
      return [];
    }
  }

  @override
  Future<bool?> removeMarker({required List<int> markerIds}) async {
    return await methodChannel.invokeMethod<bool>(
      Events.removeMarker,
      {
        'markerIds': markerIds,
      },
    );
  }

  @override
  Future<bool?> removeAllMarkers() async {
    return await methodChannel.invokeMethod<bool>(Events.removeAllMarkers);
  }

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

    if (resp?.isNotEmpty ?? false) {
      for (var i = 0; i < polylines.length; i++) {
        polylines[i].id = resp![i];
      }
      return polylines;
    } else {
      return [];
    }
  }

  @override
  Future<bool?> removePolyline({required List<int> polylineIds}) async {
    return await methodChannel.invokeMethod<bool>(
      Events.removePolyline,
      {
        'polylineIds': polylineIds,
      },
    );
  }

  @override
  Future<bool?> removeAllPolylines() async {
    return await methodChannel.invokeMethod<bool>(Events.removeAllPolylines);
  }

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

  @override
  Future<bool?> removePolygon({required List<int> polygonIds}) async {
    return await methodChannel.invokeMethod<bool>(
      Events.removePolygon,
      {
        'polygonIds': polygonIds,
      },
    );
  }

  @override
  Future<bool?> removeAllPolygons() async {
    return await methodChannel.invokeMethod<bool>(
      Events.removeAllPolygons,
    );
  }
}
