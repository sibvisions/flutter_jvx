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
import '../request/api_open_screen_request.dart';
import 'api_response.dart';

class MenuViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the menu
  final String componentId;

  /// List of all [MenuEntryResponse]
  final List<MenuEntryResponse> responseMenuItems;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MenuViewResponse.fromJson(super.json)
      : componentId = json[ApiObjectProperty.componentId],
        responseMenuItems =
            (json[ApiObjectProperty.entries] as List<dynamic>?)?.map((e) => MenuEntryResponse.fromJson(e)).toList() ??
                [],
        super.fromJson();
}

class MenuEntryResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The group this menu entry belongs to.
  final String group;

  /// Component ID of the attached screen (will be sent in [ApiOpenScreenRequest] when pressed).
  ///
  /// Example:
  /// "com.sibvisions.apps.mobile.demo.screens.features.SecondWorkScreen:L1_MI_DOOPENWORKSCREEN_COM-SIB-APP-MOB-DEM-SCR-FEA-SECWORSCR"
  final String componentId;

  /// Name used for routing (shown in the url).
  ///
  /// Example:
  /// "Second"
  final String navigationName;

  /// Text to be displayed in the menu entry.
  ///
  /// Example:
  /// "Second"
  final String text;

  /// Alternative Text to be displayed in the menu entry
  final String? sideBarText;

  /// Alternative Text to be displayed in the menu entry
  final String? quickBarText;

  /// Image to be displayed (usually Font-awesome icon)
  final String? image;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MenuEntryResponse({
    required this.componentId,
    required this.navigationName,
    required this.text,
    this.sideBarText,
    this.quickBarText,
    required this.group,
    this.image,
  });

  MenuEntryResponse.fromJson(Map<String, dynamic> json)
      : componentId = json[ApiObjectProperty.componentId],
        navigationName = json[ApiObjectProperty.navigationName],
        text = json[ApiObjectProperty.text],
        sideBarText = json[ApiObjectProperty.sideBarText],
        quickBarText = json[ApiObjectProperty.quickBarText],
        image = json[ApiObjectProperty.image],
        group = json[ApiObjectProperty.group];
}
