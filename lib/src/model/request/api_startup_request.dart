/*
 * Copyright 2022 SIB Visions GmbH
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

import '../../service/api/shared/api_object_property.dart';
import '../../service/config/i_config_service.dart';
import 'api_request.dart';

/// Request to initialize the app to the remote server
class ApiStartupRequest extends ApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The saved base url [IConfigService.baseUrl].
  final String baseUrl;

  /// The uri entered in the browser.
  final String? requestUri;

  /// Name of the JVx application.
  final String applicationName;

  /// Mode of the device.
  final String deviceMode;

  /// Current platform brightness of the device.
  final bool darkMode;

  /// Mode of this app.
  final String appMode;

  /// Total available (for WorkScreens) height of the screen.
  final int? screenHeight;

  /// Total available (for WorkScreens) width of the screen.
  final int? screenWidth;

  /// Name of the user.
  final String? username;

  /// Password of the user.
  final String? password;

  /// Auth-key from previous auto-login.
  final String? authKey;

  /// Language code.
  final String langCode;

  /// Time zone code (e.g. Europe/Vienna).
  final String timeZoneCode;

  /// How many records the app should fetch ahead.
  final int? readAheadLimit;

  /// Unique id of this device.
  final String? deviceId;

  /// The technology of this app.
  final String? technology;

  /// The os name this app runs on.
  final String? osName;

  /// The os version this app runs on.
  final String? osVersion;

  /// The app version.
  final String? appVersion;

  /// The type of device this app runs on.
  final String? deviceType;

  /// The device type model this app runs on.
  final String? deviceTypeModel;

  /// The supported server version.
  final String? serverVersion;

  /// Custom startup properties.
  final Map<String, dynamic>? customProperties;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiStartupRequest({
    required this.baseUrl,
    this.requestUri,
    required this.appMode,
    required this.deviceMode,
    required this.darkMode,
    required this.applicationName,
    required this.langCode,
    required this.timeZoneCode,
    this.screenHeight,
    this.screenWidth,
    this.username,
    this.password,
    this.authKey,
    this.customProperties,
    this.readAheadLimit,
    this.deviceId,
    this.technology,
    this.osName,
    this.osVersion,
    this.appVersion,
    this.deviceType,
    this.deviceTypeModel,
    this.serverVersion,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.baseUrl: baseUrl,
        if (requestUri != null) ApiObjectProperty.requestUri: requestUri,
        ApiObjectProperty.appMode: appMode,
        ApiObjectProperty.deviceMode: deviceMode,
        ApiObjectProperty.darkMode: darkMode,
        ApiObjectProperty.applicationName: applicationName,
        if (username != null) ApiObjectProperty.userName: username,
        if (password != null) ApiObjectProperty.password: password,
        if (screenHeight != null) ApiObjectProperty.screenHeight: screenHeight,
        if (screenWidth != null) ApiObjectProperty.screenWidth: screenWidth,
        if (authKey != null) ApiObjectProperty.authKey: authKey,
        ApiObjectProperty.langCode: langCode,
        ApiObjectProperty.timeZoneCode: timeZoneCode,
        if (readAheadLimit != null) ApiObjectProperty.readAheadLimit: readAheadLimit,
        if (deviceId != null) ApiObjectProperty.deviceId: deviceId,
        if (technology != null) ApiObjectProperty.technology: technology,
        if (osName != null) ApiObjectProperty.osName: osName,
        if (osVersion != null) ApiObjectProperty.osVersion: osVersion,
        if (appVersion != null) ApiObjectProperty.appVersion: appVersion,
        if (deviceType != null) ApiObjectProperty.deviceType: deviceType,
        if (deviceTypeModel != null) ApiObjectProperty.deviceTypeModel: deviceTypeModel,
        if (serverVersion != null) ApiObjectProperty.serverVersion: serverVersion,
        ...?customProperties?.map((key, value) => MapEntry("custom_$key", value)),
      };
}
