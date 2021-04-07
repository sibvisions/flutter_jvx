import 'package:universal_html/html.dart';

import 'device_info.dart';

class DeviceInfoWeb implements DeviceInfo {
  String? osName;
  String? osVersion;
  String? appVersion;
  String? deviceType;
  String? deviceTypeModel;
  String? technology;

  DeviceInfoWeb() {
    this.technology = "FlutterWeb";
    this.deviceType = "Chrome";
    this.deviceTypeModel = window.navigator.userAgent;
    this.osName = "Windows";
    getAppVersion().then((val) => this.appVersion = val);
    print(
        'Running on: ${this.osName} (SDK ${this.osVersion}), ${this.deviceType} ${this.deviceTypeModel}');
  }

  getAppVersion() async {
    // TODO: implement getAppVersion
  }
}

DeviceInfo getDeviceInfo() => DeviceInfoWeb();
