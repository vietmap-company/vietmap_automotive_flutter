# vietmap_automotive_flutter

This is a Flutter plugin for the [Vietmap Automotive SDK](https://maps.vietmap.vn/), which help you to integrate Vietmap turn by turn Navigation SDK into your Flutter app, included Android Auto and Apple CarPlay.

## Getting Started

1. Add the plugin to your `pubspec.yaml` file. 

```yaml
dependencies:
  vietmap_automotive_flutter: ^0.0.2
```

2. Import Android auto module to bottom of your `setting.gradle` file (top level function).
Replace `VIETMAP_AUTOMOTIVE_FLUTTER_VERSION` with the latest version of the plugin.:
```gradle

def relativePath = ""
settingsDir.eachDir { subDir ->
    if(subDir.name == "app"){
        def pathComponents =settingsDir.absolutePath.split('/')
        def rPath = ""
        pathComponents.each { component ->
            rPath += '../'
        }
        relativePath = rPath.substring(9, rPath.length())
    }
}

include ':androidauto'
project(':androidauto').projectDir = file("${relativePath}.pub-cache/hosted/pub.dev/vietmap_automotive_flutter-VIETMAP_AUTOMOTIVE_FLUTTER_VERSION/android/androidauto")
```
3. Import Android auto module to your `build.gradle` (module app) file:
```gradle
    dependencies {
        implementation project(':androidauto')
    }
```
4. Add below maven url to your `build.gradle` (project) and `setting.gradle` file:
```gradle
    maven { url = uri("https://www.jitpack.io" ) }
```


Like this 
- build.gradle
```gradle
    allprojects {
        repositories {
            google()
            mavenCentral()
            maven { url = uri("https://www.jitpack.io" ) }
        }
    }
```
- setting.gradle
```gradle
    dependencyResolutionManagement {
        repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
        repositories {
            google()
            mavenCentral()
            maven { url = uri("https://www.jitpack.io" ) }
        }
    }
```

5. Add below permission to your `AndroidManifest.xml` file:
```xml
    <uses-permission android:name="androidx.car.app.MAP_TEMPLATES" />
    <uses-permission android:name="androidx.car.app.NAVIGATION_TEMPLATES" />
    <uses-permission android:name="androidx.car.app.ACCESS_SURFACE" />
```

6. Add the following metadata to the AndroidManifest.xml file of the `app` (Inside the application tag)

```xml
    <meta-data
        android:name="com.google.android.gms.car.application"
        android:resource="@xml/automotive_app_desc" />
```

For test the app, please follow below document:
- [Test the app with Desktop Head Unit](https://github.com/vietmap-company/vietmap-android-auto/tree/main?tab=readme-ov-file#test-the-app)
- [Android Auto](https://developer.android.com/training/cars/testing)

## Features

Vietmap Automotive Flutter has a number of features to send and receive envents from Flutter to Android Auto/Apple Carplay and vice-versa:
- Adding/removing Markers
- Adding/removing Polylines
- Adding/removing Polygons
- Support for receiving callbacks from VietmapGL on Flutter side

## Implementation
1. Add the following dependencies to your pubspec.yaml:

``` yaml
dependencies:
  flutter:
    sdk: flutter
  vietmap_automotive_flutter: <latest_version>
```

2. Create an .env file in the root of your project and include the following variables:

```
VIETMAP_API_KEY=your_api_key
```

The map is initialized using VietmapAutomotiveFlutter, with callbacks to handle various events:

| Callback Parameter | Type | Usage |
| ------------------ | ---- | ----------- |
| onMapClick | `void Function(double latitude,double longitude)?` | Receive latitude and longitude when user clicks on Android Auto, Apple Carplay surface |
| onMapReady | `void Function()?` | Called when the map is fully initialized |
| onMapRendered | `void Function()?` | Called after the map is rendered |
| onMapStyleLoaded | `void Function()?` | Called when the map style is successfully loaded |

**Notes: Callbacks are optional to define, each of which are nullable**

``` dart
    // Variable Initialization
    late final VietmapAutomotiveFlutter _vietmapAutomotiveFlutterPlugin;
```
``` dart
    // Assigning instance and defining callbacks
    _vietmapAutomotiveFlutterPlugin = VietmapAutomotiveFlutter(
        onMapClick: (lat, lng) {
            setState(() {
                _location = LatLng(lat, lng);
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
```

#### Methods

| **Method** | **Signature** | **Usage** |
| ---------- | ------------- | --------- |
| initAutomotive | `Future<String?> initAutomotive({required String styleUrl, required String vietMapAPIKey});` | Initializes the map with a specified style URL and API key. |
| addMarkers | `Future<List<Marker>> addMarkers({required List<Marker> markers});` | Adds markers to the map. |
| removeMarker | `Future<bool?> removeMarker({required List<int> markerIds});`| Removes specified markers.|
| removeAllMarkers | `Future<bool?> removeAllMarkers();` | Removes all markers from the map.                           |
| addPolylines | `Future<List<Polyline>> addPolylines({required List<Polyline> polylines});` | Adds polylines to the map. |
| removePolyline | `Future<bool?> removePolyline({required List<int> polylineIds});` | Removes specified polylines. |
| removeAllPolylines | `Future<bool?> removeAllPolylines();` | Removes all polylines from the map. |
| addPolygons | `Future<List<Polygon>> addPolygons({required List<Polygon> polygons});` | Adds polygons to the map. |
| removePolygon | `Future<bool?> removePolygon({required List<int> polygonIds});` | Removes specified polygons. |
| removeAllPolygons | `Future<bool?> removeAllPolygons();` | Removes all polygons from the map. |

For sample usage of each of the function, please visit the [example project](./example/lib/main.dart) 

More information about the Vietmap Automotive SDK can be found at [Vietmap Automotive SDK](https://maps.vietmap.vn/).

<!-- cp -R ~/.pub-cache/hosted/pub.dev/vietmap_automotive_flutter-0.0.1/android/androidauto ./android -->