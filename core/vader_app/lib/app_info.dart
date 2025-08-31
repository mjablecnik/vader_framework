import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  late final String name;
  late final String version;
  late final String deviceId;
  late final String buildNumber;

  static AppInfo? _instance;

  AppInfo._() {
    loadData();
  }

  static AppInfo get instance {
    _instance ??= AppInfo._();
    return _instance!;
  }

  Future<bool> loadData() async {
    final packageInfo = (await PackageInfo.fromPlatform());
    name = packageInfo.appName;
    version = packageInfo.version;
    deviceId = await _getDeviceId();
    buildNumber = packageInfo.buildNumber;
    return true;
  }

  Future<String> _getDeviceId() async {
    final storage = await Hive.openBox('vader_app_settings');
    String? deviceId = await storage.get('deviceId');

    if (deviceId == null) {
      try {
        deviceId = await MobileDeviceIdentifier().getDeviceId();
      } catch (e) {
        debugPrint('Error getting device id: $e');
      }
      deviceId ??= generateAndroidDeviceId(secure: true);

      storage.put('deviceId', deviceId);
    }

    return deviceId;
  }

  String generateAndroidDeviceId({bool secure = false}) {
    final random = secure ? Random.secure() : Random();
    String generateHalf() =>
        random.nextInt(1 << 31).toRadixString(16).padLeft(8, '0');
    return generateHalf() + generateHalf();
  }

  @override
  String toString() {
    return 'AppInfo{name: $name, version: $version, deviceId: $deviceId, buildNumber: $buildNumber}';
  }
}
