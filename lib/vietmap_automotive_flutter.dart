
import 'vietmap_automotive_flutter_platform_interface.dart';

class VietmapAutomotiveFlutter {
  Future<String?> getPlatformVersion() {
    return VietmapAutomotiveFlutterPlatform.instance.getPlatformVersion();
  }
}
