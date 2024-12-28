import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vietmap_automotive_flutter/models/bar_button.dart';
import 'package:vietmap_automotive_flutter/models/latlng.dart';
import 'package:vietmap_automotive_flutter/models/map_button.dart';
import 'package:vietmap_automotive_flutter/models/marker.dart';
import 'package:vietmap_automotive_flutter/models/navmode.dart';
import 'package:vietmap_automotive_flutter/models/on_click_events.dart';
import 'package:vietmap_automotive_flutter/models/options.dart';
import 'package:vietmap_automotive_flutter/models/polygon.dart';
import 'package:vietmap_automotive_flutter/models/polyline.dart';
import 'package:vietmap_automotive_flutter/utils/extensions.dart';

import 'models/events.dart';
import 'models/map_template.dart';
import 'vietmap_automotive_flutter_platform_interface.dart';

/// An implementation of [VietmapAutomotiveFlutterPlatform] that uses method channels.
class MethodChannelVietmapAutomotiveFlutter
    extends VietmapAutomotiveFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vietmap_automotive_flutter');

  MethodChannelVietmapAutomotiveFlutter();

  final List<Function> _onMapReadyListeners = [];
  final List<Function(double, double)> _onMapClickListeners = [];
  final List<Function> _onMapRenderedListeners = [];
  final List<Function> _onStyleLoadedListeners = [];

  /// Set up the method channel and listen for method calls from the native platform.
  @override
  void init({
    void Function()? onMapReady,
    void Function(double latitude, double longitude)? onMapClick,
    void Function()? onMapRendered,
    void Function()? onStyleLoaded,
  }) {
    /// Set the listeners for the given events.
    if (onMapReady != null) {
      _onMapReadyListeners.add(onMapReady);
    }
    if (onMapClick != null) {
      _onMapClickListeners.add(onMapClick);
    }
    if (onMapRendered != null) {
      _onMapRenderedListeners.add(onMapRendered);
    }
    if (onStyleLoaded != null) {
      _onStyleLoadedListeners.add(onStyleLoaded);
    }

    /// Set the method call handler to listen for method calls from the native platform.
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case Events.onMapClick:
          final latitude = call.arguments['lat'] as double;
          final longitude = call.arguments['lng'] as double;
          for (var listener in _onMapClickListeners) {
            listener(latitude, longitude);
          }
          break;
        case Events.onMapReady:
          for (var listener in _onMapReadyListeners) {
            listener();
          }
          break;
        case Events.onMapRendered:
          for (var listener in _onMapRenderedListeners) {
            listener();
          }
          break;
        case Events.onStyleLoaded:
          for (var listener in _onStyleLoadedListeners) {
            listener();
          }
          break;
        default:
          debugPrint('Method not implemented');
      }
    });
  }

  /// Method to add a listener for the map click event.
  @override
  void addOnMapClickListener(Function(double, double) listener) {
    _onMapClickListeners.add(listener);
  }

  /// Method to add a listener for the map ready event.
  @override
  void addOnMapReadyListener(Function() listener) {
    _onMapReadyListeners.add(listener);
  }

  /// Method to add a listener for the map rendered event.
  @override
  void addOnMapRenderedListener(Function() listener) {
    _onMapRenderedListeners.add(listener);
  }

  /// Method to add a listener for the style loaded event.
  @override
  void addOnStyleLoadedListener(Function() listener) {
    _onStyleLoadedListeners.add(listener);
  }

  /// Method to remove a listener for the map click event.
  @override
  void removeOnMapClickListener(Function(double lat, double lng) listener) {
    _onMapClickListeners.remove(listener);
  }

  /// Method to remove a listener for the map ready event.
  @override
  void removeOnMapReadyListener(Function() listener) {
    _onMapReadyListeners.remove(listener);
  }

  /// Method to remove a listener for the map rendered event.
  @override
  void removeOnMapRenderedListener(Function() listener) {
    _onMapRenderedListeners.remove(listener);
  }

  /// Method to remove a listener for the style loaded event.
  @override
  void removeOnStyleLoadedListener(Function() listener) {
    _onStyleLoadedListeners.remove(listener);
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>(Events.getPlatformVersion);
    return version;
  }

  /// Initialize the map with the given style URL and VietMap API key.
  @override
  Future<bool?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) async {
    final initDataJson = <String, dynamic>{
      'styleUrl': styleUrl,
      'vietMapAPIKey': vietMapAPIKey,
    };
    if (Platform.isIOS) {
      final rootTemplate = CPMapTemplate(
        hidesButtonsWithNavigationBar: true,
        styleUrl: styleUrl,
        mapButtons: [
          CPMapButton(
            onClickEvent: OnClickEvents.showPanningInterface,
          ),
          CPMapButton(
            onClickEvent: OnClickEvents.recenterMapView,
          ),
          CPMapButton(
            onClickEvent: OnClickEvents.zoomInMapView,
          ),
          CPMapButton(
            onClickEvent: OnClickEvents.zoomOutMapView,
          ),
        ],
        trailingNavigationBarButtons: [
          CPBarButton(
            onClickEvent: OnClickEvents.dismissPanningInterface,
            title: 'Close',
          ),
        ],
      );
      initDataJson['rootTemplate'] = rootTemplate.toJson();
    }

    final responseMessage = await methodChannel.invokeMethod<bool>(
      Events.initAutomotive,
      initDataJson,
    );
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

  /// Build a route with the given waypoints and options.
  /// The waypoints must not have more than 3 stops on iOS.
  /// The options must have a valid profile.
  @override
  Future<bool?> buildRoute({
    required List<LatLng> waypoints,
    MapOptions? options,
    DrivingProfile profile = DrivingProfile.drivingTraffic,
  }) async {
    assert(waypoints.length > 1);
    if (Platform.isIOS && waypoints.length > 3 && options?.mode != null) {
      assert(options!.mode != MapNavigationMode.drivingWithTraffic,
          "Error: Cannot use drivingWithTraffic Mode when you have more than 3 Stops");
    }
    List<Map<String, Object?>> pointList = [];

    for (int i = 0; i < waypoints.length; i++) {
      var latLng = waypoints[i];

      final pointMap = <String, dynamic>{
        "Order": i,
        "Name": i.toString(),
        "Latitude": latLng.lat,
        "Longitude": latLng.lng,
      };
      pointList.add(pointMap);
    }
    var i = 0;
    var wayPointMap = {for (var e in pointList) i++: e};

    Map<String, dynamic> args = <String, dynamic>{};
    if (options != null) args = options.toMap();
    args["wayPoints"] = wayPointMap;

    args['profile'] = profile.getValue();
    return await methodChannel.invokeMethod(Events.buildRoute, args);
  }

  /// Overview the current selected route.
  @override
  Future<void> overviewRoute({
    MapOptions? options,
  }) async {
    Map<String, dynamic>? args;
    if (options != null) args = options.toMap();

    await methodChannel.invokeMethod(Events.overviewRoute, args);
  }

  /// Clear the current route from the map view on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the route clearing.
  @override
  Future<bool?> clearRoute() async {
    return await methodChannel.invokeMethod(Events.clearRoute);
  }

  /// Start navigation with the given options.
  /// Returns a [bool] containing the result of the navigation.
  /// or null if the navigation is not started successfully.
  @override
  Future<bool?> startNavigation({MapOptions? options}) async {
    Map<String, dynamic>? args;
    if (options != null) args = options.toMap();

    return await methodChannel.invokeMethod(Events.startNavigation, args);
  }
}
