import 'package:flutter_test/flutter_test.dart';
import 'package:vietmap_automotive_flutter/models/marker.dart';
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
  Future<String?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) {
    // TODO: implement initAutomotive
    throw UnimplementedError();
  }

  @override
  Future<List<Marker>> addMarkers({required List<Marker> markers}) {
    // TODO: implement addMarkers
    throw UnimplementedError();
  }

  @override
  Future<bool?> removeAllMarkers() {
    // TODO: implement removeAllMarkers
    throw UnimplementedError();
  }

  @override
  Future<bool?> removeMarker({required List<int> markerIds}) {
    // TODO: implement removeMarker
    throw UnimplementedError();
  }

  @override
  Future<List<Polyline>> addPolylines({required List<Polyline> polylines}) {
    // TODO: implement addPolylines
    throw UnimplementedError();
  }

  @override
  Future<bool?> removeAllPolylines() {
    // TODO: implement removeAllPolylines
    throw UnimplementedError();
  }

  @override
  Future<bool?> removePolyline({required List<int> polylineIds}) {
    // TODO: implement removePolyline
    throw UnimplementedError();
  }

  @override
  Future<List<Polygon>> addPolygons({required List<Polygon> polygons}) {
    // TODO: implement addPolygons
    throw UnimplementedError();
  }

  @override
  Future<bool?> removeAllPolygons() {
    // TODO: implement removeAllPolygons
    throw UnimplementedError();
  }

  @override
  Future<bool?> removePolygon({required List<int> polygonIds}) {
    // TODO: implement removePolygon
    throw UnimplementedError();
  }

  @override
  void init(
      {void Function()? onMapReady,
      void Function(double latitude, double longitude)? onMapClick,
      void Function()? onMapRendered,
      void Function()? onStyleLoaded}) {
    // TODO: implement init
  }
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
