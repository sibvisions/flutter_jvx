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
import '../../util/parse_util.dart';
import 'api_response.dart';

class ApplicationParametersResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Menu Bar title
  final String? applicationTitleName;

  /// Tab title
  final String? applicationTitleWeb;

  final String? authenticated;

  /// Which screen to open, is a screen name
  final String? openScreen;

  final bool? designModeAllowed;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationParametersResponse.fromJson(super.json)
      : applicationTitleName = json[ApiObjectProperty.applicationTitleName],
        applicationTitleWeb = json[ApiObjectProperty.applicationTitleWeb],
        authenticated = json[ApiObjectProperty.authenticated],
        openScreen = json[ApiObjectProperty.openScreen],
        designModeAllowed = ParseUtil.parseBool(json[ApiObjectProperty.designMode]),
        super.fromJson();
}
