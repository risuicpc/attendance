import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/services.dart' show PlatformException;

@immutable
class DeviceInfo {
  final String deviceId;
  final String androidId;

  const DeviceInfo({
    required this.deviceId,
    required this.androidId,
  });
}

Future<String> _getAndroidId() async {
  const androidIdPlugin = AndroidId();
  try {
    return await androidIdPlugin.getId() ?? 'Unknown ID';
  } on PlatformException {
    return 'Unknown ID';
  }
}

Future<String> _getDeviceId() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  try {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.id;
  } on PlatformException {
    return 'Unknown ID';
  }
}

Future<DeviceInfo> getDeviceInfo() async {
  final deviceId = await _getDeviceId();
  final androidId = await _getAndroidId();
  return DeviceInfo(deviceId: deviceId, androidId: androidId);
}
