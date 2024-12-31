import 'package:vietmap_automotive_flutter/models/marker.dart';
import 'package:vietmap_automotive_flutter/models/polyline.dart';

import 'models/latlng.dart';
import 'models/navmode.dart';
import 'models/options.dart';
import 'models/polygon.dart';
import 'vietmap_automotive_flutter_platform_interface.dart';

/// A class that provides the Vietmap Automotive Flutter API.
/// This class is used to interact with the map on Android Auto and Apple CarPlay.
class VietmapAutomotiveFlutter {
  final VietmapAutomotiveFlutterPlatform _vietmapAutomotiveFlutterPlatform =
      VietmapAutomotiveFlutterPlatform.instance;

  /// Called when the map is ready to be used.
  final void Function()? onMapReady;

  /// Called when the map is clicked on Android Auto and Apple Carplay map surface.
  final void Function(
    double latitude,
    double longitude,
  )? onMapClick;

  /// Called when the map is rendered.
  final void Function()? onMapRendered;

  /// Called when the style is loaded.
  final void Function()? onStyleLoaded;

  /// Constructs a [VietmapAutomotiveFlutter].
  /// [onMapReady] is called when the map is ready to be used.
  /// [onMapClick] is called when the map is clicked.
  /// [onMapRendered] is called when the map is rendered.
  /// [onStyleLoaded] is called when the style is loaded.
  VietmapAutomotiveFlutter({
    this.onMapReady,
    this.onMapClick,
    this.onMapRendered,
    this.onStyleLoaded,
  }) {
    _initPlatformInterface();
  }

  /// Adds a listener to the map ready event.
  void addMapReadyListener(Function() listener) {
    _vietmapAutomotiveFlutterPlatform.addOnMapReadyListener(listener);
  }

  /// Adds a listener to the map click event.
  void addMapClickListener(Function(double, double) listener) {
    _vietmapAutomotiveFlutterPlatform.addOnMapClickListener(listener);
  }

  /// Adds a listener to the map rendered event.
  void addMapRenderedListener(Function() listener) {
    _vietmapAutomotiveFlutterPlatform.addOnMapRenderedListener(listener);
  }

  /// Adds a listener to the style loaded event.
  void addStyleLoadedListener(Function() listener) {
    _vietmapAutomotiveFlutterPlatform.addOnStyleLoadedListener(listener);
  }

  /// Removes a listener from the map ready event.
  void removeMapReadyListener(Function() listener) {
    _vietmapAutomotiveFlutterPlatform.removeOnMapReadyListener(listener);
  }

  /// Removes a listener from the map click event.
  void removeMapClickListener(Function(double, double) listener) {
    _vietmapAutomotiveFlutterPlatform.removeOnMapClickListener(listener);
  }

  /// Removes a listener from the map rendered event.
  void removeMapRenderedListener(Function() listener) {
    _vietmapAutomotiveFlutterPlatform.removeOnMapRenderedListener(listener);
  }

  /// Removes a listener from the style loaded event.
  void removeStyleLoadedListener(Function() listener) {
    _vietmapAutomotiveFlutterPlatform.removeOnStyleLoadedListener(listener);
  }

  Future<String?> getPlatformVersion() {
    return _vietmapAutomotiveFlutterPlatform.getPlatformVersion();
  }

  /// Initializes the map on Android Auto and Apple CarPlay with the given [styleUrl] and [vietMapAPIKey].
  /// Returns a [String] containing the result of the initialization.
  /// car_app_initialized is returned if the map is initialized successfully.
  /// or null if the map is not initialized successfully.
  Future<bool?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) async {
    return await _vietmapAutomotiveFlutterPlatform.initAutomotive(
        styleUrl: styleUrl, vietMapAPIKey: vietMapAPIKey);
  }

  /// Add markers to the map view on Android Auto and Apple CarPlay.
  /// Returns a [List] of [Marker] containing the added markers.
  /// or empty list if the markers are not added successfully.
  Future<List<Marker>> addMarkers({
    required List<Marker> markers,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.addMarkers(markers: markers);
  }

  /// Remove selected markers with the given [markerIds] from the map view on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the removal.
  Future<bool?> removeMarker({required List<int> markerIds}) async {
    return await _vietmapAutomotiveFlutterPlatform.removeMarker(
        markerIds: markerIds);
  }

  /// Remove all markers from the map view on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the removal.
  Future<bool?> removeAllMarkers() async {
    return await _vietmapAutomotiveFlutterPlatform.removeAllMarkers();
  }

  /// Add polylines to the map view on Android Auto and Apple CarPlay.
  /// Returns a [List] of [Polyline] containing the added polylines.
  /// or empty list if the polylines are not added successfully.
  Future<List<Polyline>> addPolylines({
    required List<Polyline> polylines,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.addPolylines(
        polylines: polylines);
  }

  /// Remove selected polylines with the given [polylineIds] from the map view on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the removal.
  Future<bool?> removePolyline({required List<int> polylineIds}) async {
    return await _vietmapAutomotiveFlutterPlatform.removePolyline(
        polylineIds: polylineIds);
  }

  /// Remove all polylines from the map view on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the removal.
  Future<bool?> removeAllPolylines() async {
    return await _vietmapAutomotiveFlutterPlatform.removeAllPolylines();
  }

  /// Add polygons to the map view on Android Auto and Apple CarPlay.
  /// Returns a [List] of [Polygon] containing the added polygons.
  /// or empty list if the polygons are not added successfully.
  Future<List<Polygon>> addPolygons({
    required List<Polygon> polygons,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.addPolygons(
        polygons: polygons);
  }

  /// Remove selected polygons with the given [polygonIds] from the map view on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the removal.
  Future<bool?> removePolygon({required List<int> polygonIds}) async {
    return await _vietmapAutomotiveFlutterPlatform.removePolygon(
        polygonIds: polygonIds);
  }

  /// Remove all polygons from the map view on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the removal.
  Future<bool?> removeAllPolygons() async {
    return await _vietmapAutomotiveFlutterPlatform.removeAllPolygons();
  }

  /// Builds a route with the given [waypoints] and [options].
  /// Returns a [bool] containing the result of the route building.
  /// or false if the route is not built successfully.
  /// The [profile] parameter is optional and defaults to [DrivingProfile.drivingTraffic].
  Future<bool?> buildRoute({
    required List<LatLng> waypoints,
    MapOptions? options,
    DrivingProfile profile = DrivingProfile.drivingTraffic,
    bool startNavigation = false,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.buildRoute(
      waypoints: waypoints,
      options: options,
      profile: profile,
      startNavigation: startNavigation,
    );
  }

  /// Starts a free drive with the given [options].
  /// Returns a [bool] containing the result of the free drive.
  /// or false if the free drive is not started successfully.
  Future<void> overviewRoute({
    MapOptions? options,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.overviewRoute(
      options: options,
    );
  }

  /// Clears the route from the map view on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the route clearing.
  Future<bool?> clearRoute() async {
    return await _vietmapAutomotiveFlutterPlatform.clearRoute();
  }

  /// Starts navigation with the given [options].
  /// Returns a [bool] containing the result of the navigation.
  /// or false if the navigation is not started successfully.
  Future<bool?> startNavigation({
    MapOptions? options,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.startNavigation(
      options: options,
    );
  }

  /// Re-centers the map view to the current location.
  Future<void> recenter({MapOptions? options}) async {
    return await _vietmapAutomotiveFlutterPlatform.recenter(
      options: options,
    );
  }

  /// Stops the navigation on Android Auto and Apple CarPlay.
  /// Returns a [bool] containing the result of the navigation stopping.
  /// or null if the navigation is not stopped successfully.
  Future<bool?> stopNavigation() async {
    return await _vietmapAutomotiveFlutterPlatform.stopNavigation();
  }

  /// Zooms in the map view on Android Auto and Apple CarPlay.
  Future<void> zoomIn() async {
    return await _vietmapAutomotiveFlutterPlatform.zoomIn();
  }

  /// Zooms out the map view on Android Auto and Apple CarPlay.
  Future<void> zoomOut() async {
    return await _vietmapAutomotiveFlutterPlatform.zoomOut();
  }

  /// Moves the camera to the given [latLng] with optional [bearing], [zoom], and [tilt] on Android Auto and Apple CarPlay.
  Future<void> moveCamera(
      {required LatLng latLng,
      double? bearing,
      double? zoom,
      double? tilt}) async {
    return _vietmapAutomotiveFlutterPlatform.moveCamera(
      latLng: latLng,
      bearing: bearing,
      zoom: zoom,
      tilt: tilt,
    );
  }

  /// Animate the camera to the given [LatLng] with optional bearing, zoom, tilt, and duration.
  /// The default duration is 1000 milliseconds.
  Future<void> animateCamera(
      {required LatLng latLng,
      double? bearing,
      Duration duration = const Duration(milliseconds: 1000),
      double? zoom,
      double? tilt}) async {
    return _vietmapAutomotiveFlutterPlatform.animateCamera(
      latLng: latLng,
      bearing: bearing,
      duration: duration,
      zoom: zoom,
      tilt: tilt,
    );
  }

  /// Get the distance remaining to the destination on the current route.
  /// Returns the distance remaining to the destination in selected unit.
  Future<double?> getDistanceRemaining() async {
    return await _vietmapAutomotiveFlutterPlatform.getDistanceRemaining();
  }

  /// Get the duration remaining to the destination on the current route.
  Future<double?> getDurationRemaining() async {
    return await _vietmapAutomotiveFlutterPlatform.getDurationRemaining();
  }

  /// Toggle mute on Android Auto and Apple CarPlay during navigation.
  /// Returns a [bool] containing the result of the mute toggling.
  /// The boolean value is true if the mute is enabled, false otherwise.
  Future<bool?> toggleMute({
    required bool isMuted,
  }) async {
    return await _vietmapAutomotiveFlutterPlatform.toggleMute(isMuted);
  }

  void _initPlatformInterface() {
    _vietmapAutomotiveFlutterPlatform.init(
      onMapReady: onMapReady,
      onMapClick: onMapClick,
      onMapRendered: onMapRendered,
      onStyleLoaded: onStyleLoaded,
    );
  }
}
