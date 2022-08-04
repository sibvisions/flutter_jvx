import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'device_info.dart';

class DeviceInfoMobile implements DeviceInfo {
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

  DeviceInfoMobile();

  @override
  Future<void> setSystemInfo() async {
    technology = "FlutterMobile";

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      osName = 'Android ${androidInfo.version.release}';
      osVersion = androidInfo.version.sdkInt.toString();
      deviceType = androidInfo.manufacturer;
      deviceTypeModel = androidInfo.model;
      deviceId = androidInfo.androidId;
    }

    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      osName = iosInfo.systemName;
      osVersion = iosInfo.systemVersion;
      deviceTypeModel = iosInfo.name;
      deviceType = iosInfo.model;
      deviceId = iosInfo.identifierForVendor;
    }
  }
}

DeviceInfo getDeviceInfo() => DeviceInfoMobile();
