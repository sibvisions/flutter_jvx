import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:platform_detect/platform_detect.dart';
import 'dart:html';

import '../../../injection_container.dart';
import 'device_info.dart';

class DeviceInfoWeb implements DeviceInfo {
  String osName;
  String osVersion;
  String appVersion;
  String deviceType;
  String deviceTypeModel;
  String technology;

  DeviceInfoWeb() {
    this.technology = "FlutterWeb";
    this.deviceType = browser.name;
    this.deviceTypeModel = window.navigator.userAgent;
    this.osName = operatingSystem.name;
    getAppVersion().then((val) => this.appVersion = val);
    print(
        'Running on: ${this.osName} (SDK ${this.osVersion}), ${this.deviceType} ${this.deviceTypeModel}');
  }

  getAppVersion() async {
    AppState appState = sl<AppState>();
    Map<String, dynamic> buildversion = json.decode(await rootBundle.loadString(
        appState.package
            ? "packages/jvx_flutterclient/env/app.conf.json"
            : "env/app.conf.json"));
    return buildversion['version'];
  }
}

DeviceInfo getDeviceInfo() => DeviceInfoWeb();
