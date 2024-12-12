import 'vietmap_automotive_flutter_platform_interface.dart';

class VietmapAutomotiveFlutter {
  Future<String?> getPlatformVersion() {
    return VietmapAutomotiveFlutterPlatform.instance.getPlatformVersion();
  }

  Future<String?> initAutomotive(
      {required String styleUrl, required String vietMapAPIKey}) {
    return VietmapAutomotiveFlutterPlatform.instance
        .initAutomotive(styleUrl: styleUrl, vietMapAPIKey: vietMapAPIKey);
  }
}
