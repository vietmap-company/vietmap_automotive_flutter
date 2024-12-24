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
  debugPrint('Error: $error');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  void customizeOnMapClick(double lat, double lng) {
    print('From customizeOnMapClick: Lat: $lat, Lng: $lng');
  }

  void customizeOnMapReady() {
    print('From customizeOnMapReady');
  }

  void customizeOnMapRendered() {
    print('From customizeOnMapRendered');
  }

  void customizeOnStyleLoaded() {
    print('From customizeOnStyleLoaded');
  }

  Future<void> initStateFunc() async {
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

      _vietmapAutomotiveFlutterPlugin.addMapClickListener(customizeOnMapClick);
      _vietmapAutomotiveFlutterPlugin.addMapReadyListener(customizeOnMapReady);
      _vietmapAutomotiveFlutterPlugin
          .addMapRenderedListener(customizeOnMapRendered);
      _vietmapAutomotiveFlutterPlugin
          .addStyleLoadedListener(customizeOnStyleLoaded);

      await _vietmapAutomotiveFlutterPlugin.initAutomotive(
        styleUrl: AppContext.getVietmapMapStyleUrl(),
        vietMapAPIKey: AppContext.getVietmapAPIKey(),
      );
    } catch (e) {
      debugPrint('Error: $e');
    }
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
                          latLng: const LatLng(
                              lat: 10.759238582476392, lng: 106.67595730119154),
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
                          const LatLng(
                              lat: 10.759238582476392, lng: 106.67595730119154),
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _vietmapAutomotiveFlutterPlugin
                      .removeMapClickListener(customizeOnMapClick);
                },
                child: const Text('Remove onMapClick Listener'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _vietmapAutomotiveFlutterPlugin
                      .removeMapReadyListener(customizeOnMapReady);
                },
                child: const Text('Remove onMapReady Listener'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _vietmapAutomotiveFlutterPlugin
                      .removeMapRenderedListener(customizeOnMapRendered);
                },
                child: const Text('Remove onMapRendered Listener'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _vietmapAutomotiveFlutterPlugin
                      .removeStyleLoadedListener(customizeOnStyleLoaded);
                },
                child: const Text('Remove onStyleLoaded Listener'),
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
