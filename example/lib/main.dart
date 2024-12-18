import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vietmap_automotive_flutter/models/latlng.dart';
import 'package:vietmap_automotive_flutter/models/marker.dart';
import 'package:vietmap_automotive_flutter/models/polygon.dart';
import 'package:vietmap_automotive_flutter/models/polyline.dart';
import 'package:vietmap_automotive_flutter/vietmap_automotive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'di/app_context.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");
      runApp(const MyApp());
    },
    onError,
  );
}

void onError(Object error, StackTrace stackTrace) {
  print('Error: $error');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  LatLng? _latLng;
  bool _isMapReady = false;
  bool _isMapRendered = false;
  bool _isStyleLoaded = false;
  late final VietmapAutomotiveFlutter _vietmapAutomotiveFlutterPlugin;
  final _markers = <Marker>[];
  final _polylines = <Polyline>[];
  final _polygons = <Polygon>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await Future.wait(
          [
            requestPermission(),
            initStateFunc(),
          ],
        );
      },
    );
  }

  Future<void> requestPermission() async {
    final res = await Geolocator.checkPermission();
    if (res != LocationPermission.always ||
        res != LocationPermission.whileInUse) {
      await Geolocator.requestPermission();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initStateFunc() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      _vietmapAutomotiveFlutterPlugin = VietmapAutomotiveFlutter(
        onMapClick: (lat, lng) {
          setState(() {
            _latLng = LatLng(lat: lat, lng: lng);
          });
        },
        onMapReady: () {
          setState(() {
            _isMapReady = true;
          });
        },
        onMapRendered: () {
          setState(() {
            _isMapRendered = true;
          });
        },
        onStyleLoaded: () {
          setState(() {
            _isStyleLoaded = true;
          });
        },
      );

      _vietmapAutomotiveFlutterPlugin.init();
      platformVersion =
          await _vietmapAutomotiveFlutterPlugin.getPlatformVersion() ??
              'Unknown platform version';
      await _vietmapAutomotiveFlutterPlugin.initAutomotive(
        styleUrl: AppContext.getVietmapMapStyleUrl(),
        vietMapAPIKey: AppContext.getVietmapAPIKey(),
      );
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Text(
                'Running on: $_platformVersion',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final resp = await _vietmapAutomotiveFlutterPlugin.addMarkers(
                    markers: [
                      Marker(
                          width: 120,
                          height: 120,
                          imagePath: 'assets/50.png',
                          latLng:
                              const LatLng(lat: 10.762528, lng: 106.653099)),
                      Marker(
                          imagePath: 'assets/40.png',
                          latLng: const LatLng(lat: 10.762528, lng: 106.753099),
                          width: 80,
                          height: 80),
                    ],
                  );
                  _markers.addAll(resp);
                },
                child: const Text(
                  'Add Markers',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final resp =
                      await _vietmapAutomotiveFlutterPlugin.addPolylines(
                    polylines: [
                      Polyline(
                        points: [
                          const LatLng(lat: 10.762528, lng: 106.653099),
                          const LatLng(lat: 10.762528, lng: 106.753099),
                          const LatLng(lat: 10.57234, lng: 106.853099),
                        ],
                        width: 6,
                      ),
                    ],
                  );
                  _polylines.addAll(resp);
                },
                child: const Text('Add Polyline'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final resp =
                      await _vietmapAutomotiveFlutterPlugin.addPolygons(
                    polygons: [
                      Polygon(
                        points: [
                          const LatLng(lat: 10.762528, lng: 106.653099),
                          const LatLng(lat: 10.762528, lng: 106.753099),
                          const LatLng(lat: 10.57234, lng: 106.853099),
                        ],
                        fillColor: Colors.red,
                      ),
                    ],
                  );
                  _polygons.addAll(resp);
                },
                child: const Text('Add Polygon'),
              ),
              const SizedBox(height: 10),
              Text(
                'Map Click: ${_latLng != null ? 'Lat: ${_latLng!.lat}, Lng: ${_latLng!.lng}' : 'Not Clicked'}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Map Ready: $_isMapReady',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Map Rendered: $_isMapRendered',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Style Loaded: $_isStyleLoaded',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                await _vietmapAutomotiveFlutterPlugin.removeAllMarkers();
                _markers.clear();
              },
              child: const Icon(Icons.location_off),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () async {
                await _vietmapAutomotiveFlutterPlugin.removeMarker(
                  markerIds: _markers.map((e) => e.markerId ?? 0).toList(),
                );
                _markers.clear();
              },
              child: const Icon(Icons.location_off_rounded),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () async {
                await _vietmapAutomotiveFlutterPlugin.removeAllPolylines();
                _polylines.clear();
              },
              child: const Icon(Icons.route),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () async {
                await _vietmapAutomotiveFlutterPlugin.removePolyline(
                  polylineIds: _polylines.map((e) => e.id ?? 0).toList(),
                );
                _polylines.clear();
              },
              child: const Icon(Icons.route),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () async {
                await _vietmapAutomotiveFlutterPlugin.removeAllPolygons();
                _polygons.clear();
              },
              child: const Icon(Icons.rectangle),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () async {
                await _vietmapAutomotiveFlutterPlugin.removePolygon(
                  polygonIds: _polygons.map((e) => e.id ?? 0).toList(),
                );
                _polygons.clear();
              },
              child: const Icon(Icons.rectangle),
            ),
          ],
        ),
      ),
    );
  }
}
