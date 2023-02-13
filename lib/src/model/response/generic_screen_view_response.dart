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

class GenericScreenViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the screen.
  ///
  /// Example:
  /// "Sec-BL"
  final String screenName;

  /// List of all changed and new components
  final List<dynamic>? changedComponents;

  /// False if this should be displayed on top
  final bool update;
  final bool home;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GenericScreenViewResponse({
    required this.screenName,
    required this.changedComponents,
    required this.home,
    required this.update,
    required super.name,
  });

  GenericScreenViewResponse.fromJson(super.json)
      : screenName = json[ApiObjectProperty.componentId],
        changedComponents = json[ApiObjectProperty.changedComponents],
        update = json[ApiObjectProperty.update],
        home = json[ApiObjectProperty.home],
        super.fromJson();
}
