/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfo {
  String? appVersion;
  String? technology;
  String? osName;
  String? osVersion;
  String? deviceType;
  String? deviceTypeModel;
  String? deviceId;

  DeviceInfo({
    this.appVersion,
    this.technology,
    this.osName,
    this.osVersion,
    this.deviceType,
    this.deviceTypeModel,
    this.deviceId,
  });

  static fromPlatform() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfo deviceInfo;

    if (kIsWeb) {
      var webBrowserInfo = await DeviceInfoPlugin().webBrowserInfo;
      deviceInfo = DeviceInfo(
        osName: webBrowserInfo.platform,
        deviceType: webBrowserInfo.browserName.name,
        deviceTypeModel: webBrowserInfo.userAgent,
        technology: "FlutterWeb",
      );
    } else {
      if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceInfo = DeviceInfo(
          osName: "Android ${androidInfo.version.release}",
          osVersion: androidInfo.version.sdkInt.toString(),
          deviceType: androidInfo.manufacturer,
          deviceTypeModel: androidInfo.model,
        );
      } else if (Platform.isIOS) {
        var iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceInfo = DeviceInfo(
          osName: iosInfo.systemName,
          osVersion: iosInfo.systemVersion,
          deviceTypeModel: iosInfo.name,
          deviceType: iosInfo.model,
          deviceId: iosInfo.identifierForVendor,
        );
      } else {
        deviceInfo = DeviceInfo();
      }
    }

    return deviceInfo
      ..technology ??= "FlutterMobile"
      ..appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
  }
}
