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
def VIETMAP_AUTOMOTIVE_FLUTTER_VERSION = "0.0.3-pre.1"
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
project(':androidauto').projectDir = file("${relativePath}.pub-cache/hosted/pub.dev/vietmap_automotive_flutter-${VIETMAP_AUTOMOTIVE_FLUTTER_VERSION}/android/androidauto")
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

More information about the Vietmap Automotive SDK can be found at [Vietmap Automotive SDK](https://maps.vietmap.vn/).

<!-- cp -R ~/.pub-cache/hosted/pub.dev/vietmap_automotive_flutter-0.0.1/android/androidauto ./android -->