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

import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class LanguageResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Lang code of the app
  final String langCode;

  /// Time zone code of the app
  final String? timeZoneCode;

  final String? languageResource;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LanguageResponse({
    required this.langCode,
    this.timeZoneCode,
    this.languageResource,
    required super.name,
  });

  LanguageResponse.fromJson(super.json)
      : langCode = json[ApiObjectProperty.langCode],
        timeZoneCode = json[ApiObjectProperty.timeZoneCode],
        languageResource = json[ApiObjectProperty.languageResource],
        super.fromJson();

  @override
  String toString() {
    return 'LanguageResponse{langCode: $langCode, timeZoneCode: $timeZoneCode, languageResource: $languageResource}';
  }
}
