import 'package:flutter_test/flutter_test.dart';
import 'package:vietmap_automotive_flutter/models/latlng.dart';
import 'package:vietmap_automotive_flutter/models/marker.dart';
import 'package:vietmap_automotive_flutter/models/navmode.dart';
import 'package:vietmap_automotive_flutter/models/options.dart';
import 'package:vietmap_automotive_flutter/models/polygon.dart';
import 'package:vietmap_automotive_flutter/models/polyline.dart';
import 'package:vietmap_automotive_flutter/vietmap_automotive_flutter.dart';
import 'package:vietmap_automotive_flutter/vietmap_automotive_flutter_platform_interface.dart';
import 'package:vietmap_automotive_flutter/vietmap_automotive_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVietmapAutomotiveFlutterPlatform
    with MockPlatformInterfaceMixin
    implements VietmapAutomotiveFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Marker>> addMarkers({required List<Marker> markers}) {
    throw UnimplementedError();
  }

  @override
  Future<bool?> removeAllMarkers() {
    throw UnimplementedError();
  }

  @override
  Future<bool?> removeMarker({required List<int> markerIds}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Polyline>> addPolylines({required List<Polyline> polylines}) {
    throw UnimplementedError();
  }

  @override
  Future<bool?> removeAllPolylines() {
    throw UnimplementedError();
  }

  @override
  Future<bool?> removePolyline({required List<int> polylineIds}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Polygon>> addPolygons({required List<Polygon> polygons}) {
    throw UnimplementedError();
  }

  @override
  Future<bool?> removeAllPolygons() {
    throw UnimplementedError();
  }

  @override
  Future<bool?> removePolygon({required List<int> polygonIds}) {
    throw UnimplementedError();
  }

  @override
  void init(
      {void Function()? onMapReady,
      void Function(double latitude, double longitude)? onMapClick,
      void Function()? onMapRendered,
      void Function()? onStyleLoaded}) {}

  @override
  void addOnMapClickListener(Function(double p1, double p2) listener) {}

  @override
  void addOnMapReadyListener(Function() listener) {}

  @override
  void addOnMapRenderedListener(Function() listener) {}

  @override
  void addOnStyleLoadedListener(Function() listener) {}

  @override
  void removeOnMapClickListener(Function(double lat, double lng) listener) {}

  @override
  void removeOnMapReadyListener(Function() listener) {}

  @override
  void removeOnMapRenderedListener(Function() listener) {}

  @override
  void removeOnStyleLoadedListener(Function() listener) {}

  @override
  Future<bool> buildRoute({
    required List<LatLng> waypoints,
    MapOptions? options,
    profile = DrivingProfile.drivingTraffic,
    bool startNavigation = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> overviewRoute({MapOptions? options}) async {}

  @override
  Future<bool> clearRoute() {
    throw UnimplementedError();
  }

  @override
  Future<bool?> startNavigation({MapOptions? options}) {
    throw UnimplementedError();
  }

  @override
  Future<void> recenter({MapOptions? options}) {
    throw UnimplementedError();
  }

  @override
  Future<bool?> stopNavigation() {
    throw UnimplementedError();
  }

  @override
  Future<void> zoomIn() {
    throw UnimplementedError();
  }

  @override
  Future<void> zoomOut() {
    throw UnimplementedError();
  }

  @override
  Future<void> moveCamera(
      {required LatLng latLng, double? bearing, double? zoom, double? tilt}) {
    throw UnimplementedError();
  }

  @override
  Future<void> animateCamera(
      {required LatLng latLng,
      double? bearing,
      Duration duration = const Duration(milliseconds: 1000),
      double? zoom,
      double? tilt}) {
    throw UnimplementedError();
  }

  @override
  Future<double?> getDistanceRemaining() {
    throw UnimplementedError();
  }

  @override
  Future<double?> getDurationRemaining() {
    throw UnimplementedError();
  }

  @override
  Future<bool?> toggleMute(bool isMute) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}

  @override
  void addOnNavigationRunningListener(Function() listener) {}

  @override
  void removeOnNavigationRunningListener(Function() listener) {}
}

void main() {
  final VietmapAutomotiveFlutterPlatform initialPlatform =
      VietmapAutomotiveFlutterPlatform.instance;

  test('$MethodChannelVietmapAutomotiveFlutter is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelVietmapAutomotiveFlutter>());
  });

  test('getPlatformVersion', () async {
    VietmapAutomotiveFlutter vietmapAutomotiveFlutterPlugin =
        VietmapAutomotiveFlutter();
    MockVietmapAutomotiveFlutterPlatform fakePlatform =
        MockVietmapAutomotiveFlutterPlatform();
    VietmapAutomotiveFlutterPlatform.instance = fakePlatform;

    expect(await vietmapAutomotiveFlutterPlugin.getPlatformVersion(), '42');
  });
}
