import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';

import 'device_info.dart';

class DeviceInfoMobile implements DeviceInfo {
  String? osName;
  String? osVersion;
  String? appVersion;
  String? deviceType;
  String? deviceTypeModel;
  String? technology;

  DeviceInfoMobile();

  Future<void> setSystemInfo() async {
    this.technology = "FlutterMobile";

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      this.osName = 'Android ${androidInfo.version.release}';
      this.osVersion = androidInfo.version.sdkInt.toString();
      this.deviceType = androidInfo.manufacturer;
      this.deviceTypeModel = androidInfo.model;
    }

    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      this.osName = iosInfo.systemName;
      this.osVersion = iosInfo.systemVersion;
      this.deviceTypeModel = iosInfo.name;
      this.deviceType = iosInfo.model;
    }

    print(
        'Running on: ${this.osName} (${this.osVersion}), ${this.deviceType} ${this.deviceTypeModel}');
  }
}

DeviceInfo getDeviceInfo() => DeviceInfoMobile();
