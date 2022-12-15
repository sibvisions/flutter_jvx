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
import 'api_request.dart';

/// Request to initialize the app to the remote server
class ApiStartUpRequest extends ApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the JVx application
  final String applicationName;

  /// Mode of the Device
  final String deviceMode;

  /// Mode of this app
  final String appMode;

  /// Total available (for workscreens) width of the screen
  final int? screenWidth;

  /// Total available (for workscreens) height of the screen
  final int? screenHeight;

  /// Name of the user
  final String? username;

  /// Password of the user
  final String? password;

  /// Auth-key from previous auto-login
  final String? authKey;

  /// Language code
  final String langCode;

  /// Time zone code (e.g. Europe/Vienna)
  final String timeZoneCode;

  /// How many records the app should fetch ahead
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

  /// Custom startup parameters
  final Map<String, dynamic>? startUpParameters;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiStartUpRequest({
    required this.appMode,
    required this.deviceMode,
    required this.applicationName,
    required this.langCode,
    required this.timeZoneCode,
    this.screenHeight,
    this.screenWidth,
    this.username,
    this.password,
    this.authKey,
    this.startUpParameters,
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
        ApiObjectProperty.appMode: appMode,
        ApiObjectProperty.deviceMode: deviceMode,
        ApiObjectProperty.applicationName: applicationName,
        ApiObjectProperty.userName: username,
        ApiObjectProperty.password: password,
        ApiObjectProperty.screenWidth: screenWidth,
        ApiObjectProperty.screenHeight: screenHeight,
        ApiObjectProperty.authKey: authKey,
        ApiObjectProperty.langCode: langCode,
        ApiObjectProperty.timeZoneCode: timeZoneCode,
        ApiObjectProperty.readAheadLimit: readAheadLimit,
        ApiObjectProperty.deviceId: deviceId,
        ApiObjectProperty.technology: technology,
        ApiObjectProperty.osName: osName,
        ApiObjectProperty.osVersion: osVersion,
        ApiObjectProperty.appVersion: appVersion,
        ApiObjectProperty.deviceType: deviceType,
        ApiObjectProperty.deviceTypeModel: deviceTypeModel,
        ApiObjectProperty.serverVersion: serverVersion,
        ...?startUpParameters
      };
}
