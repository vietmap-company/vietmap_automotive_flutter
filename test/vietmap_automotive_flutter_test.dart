import 'package:flutter_test/flutter_test.dart';
import 'package:vietmap_automotive_flutter/vietmap_automotive_flutter.dart';
import 'package:vietmap_automotive_flutter/vietmap_automotive_flutter_platform_interface.dart';
import 'package:vietmap_automotive_flutter/vietmap_automotive_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVietmapAutomotiveFlutterPlatform
    with MockPlatformInterfaceMixin
    implements VietmapAutomotiveFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VietmapAutomotiveFlutterPlatform initialPlatform = VietmapAutomotiveFlutterPlatform.instance;

  test('$MethodChannelVietmapAutomotiveFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVietmapAutomotiveFlutter>());
  });

  test('getPlatformVersion', () async {
    VietmapAutomotiveFlutter vietmapAutomotiveFlutterPlugin = VietmapAutomotiveFlutter();
    MockVietmapAutomotiveFlutterPlatform fakePlatform = MockVietmapAutomotiveFlutterPlatform();
    VietmapAutomotiveFlutterPlatform.instance = fakePlatform;

    expect(await vietmapAutomotiveFlutterPlugin.getPlatformVersion(), '42');
  });
}
