import 'dart:html';

import 'device_info.dart';

class DeviceInfoWeb implements DeviceInfo {
  @override
  String? osName;
  @override
  String? osVersion;
  @override
  String? appVersion;
  @override
  String? deviceType;
  @override
  String? deviceTypeModel;
  @override
  String? technology;
  @override
  String? deviceId;

  DeviceInfoWeb();

  @override
  Future<void> setSystemInfo() async {
    osName = "Windows";
    technology = "FlutterWeb";
    deviceType = "Chrome";
    deviceTypeModel = window.navigator.userAgent;
  }
}

DeviceInfo getDeviceInfo() => DeviceInfoWeb();
