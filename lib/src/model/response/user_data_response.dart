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

/// Contains all user specific data
class UserDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Unique name
  final String userName;

  /// Name to display
  final String displayName;

  /// Email of the user
  final String? eMail;

  /// Profile image of the user
  final String? profileImage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UserDataResponse({
    required this.displayName,
    required this.userName,
    required this.eMail,
    required this.profileImage,
    required super.name,
  });

  UserDataResponse.fromJson(super.json)
      : userName = json[ApiObjectProperty.userName],
        displayName = json[ApiObjectProperty.displayName],
        eMail = json[ApiObjectProperty.eMail],
        profileImage = json[ApiObjectProperty.profileImage],
        super.fromJson();
}
