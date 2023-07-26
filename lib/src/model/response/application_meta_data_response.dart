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
import 'api_response.dart';

class ApplicationMetaDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// SessionId
  final String clientId;

  /// Name of the remote app
  final String? applicationName;

  /// Version of the remote app
  final String version;

  /// Version of the server
  final String? serverVersion;

  /// Lang code of the app
  final String langCode;

  /// Time zone code of the app
  final String? timeZoneCode;

  /// Whether lost password feature is enabled.
  final bool lostPasswordEnabled;

  /// Whether lost password feature is enabled.
  final bool? rememberMeEnabled;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationMetaDataResponse({
    required this.clientId,
    this.applicationName,
    required this.version,
    this.serverVersion,
    required this.langCode,
    this.timeZoneCode,
    required this.lostPasswordEnabled,
    this.rememberMeEnabled,
    required super.name,
  });

  ApplicationMetaDataResponse.fromJson(super.json)
      : clientId = json[ApiObjectProperty.clientId],
        applicationName = json[ApiObjectProperty.applicationName],
        version = json[ApiObjectProperty.version],
        serverVersion = json[ApiObjectProperty.serverVersion],
        langCode = json[ApiObjectProperty.langCode],
        timeZoneCode = json[ApiObjectProperty.timeZoneCode],
        lostPasswordEnabled = json[ApiObjectProperty.lostPasswordEnabled],
        rememberMeEnabled = json[ApiObjectProperty.rememberMe],
        super.fromJson();

  @override
  String toString() {
    return 'ApplicationMetaDataResponse{clientId: $clientId, applicationName: $applicationName, version: $version, serverVersion: $serverVersion, langCode: $langCode, timeZoneCode: $timeZoneCode, lostPasswordEnabled: $lostPasswordEnabled, rememberMeEnabled: $rememberMeEnabled}';
  }
}
