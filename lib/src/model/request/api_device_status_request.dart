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
import 'session_request.dart';

/// Request to update device properties (e.g. the available screen size) to the app.
class ApiDeviceStatusRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Available height of the device for work-screens.
  final int? screenHeight;

  /// Available width of the device for work-screens.
  final int? screenWidth;

  /// Describes the current platform brightness.
  final bool? darkMode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDeviceStatusRequest({
    this.screenHeight,
    this.screenWidth,
    this.darkMode,
  });

  ApiDeviceStatusRequest merge(ApiDeviceStatusRequest? other) {
    if (other == null) return this;

    return ApiDeviceStatusRequest(
      screenHeight: other.screenHeight ?? screenHeight,
      screenWidth: other.screenWidth ?? screenWidth,
      darkMode: other.darkMode ?? darkMode,
    );
  }

  /// Whether this object has new properties in comparison to [other].
  ///
  /// `null` values are not considered as "new".
  bool hasNewProperties(ApiDeviceStatusRequest? other) {
    if (other == null) return true;

    return !identical(this, other) &&
        ((other.screenHeight != screenHeight && screenHeight != null) ||
            (other.screenWidth != screenWidth && screenWidth != null) ||
            (other.darkMode != darkMode && darkMode != null));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        if (screenHeight != null) ApiObjectProperty.screenHeight: screenHeight,
        if (screenWidth != null) ApiObjectProperty.screenWidth: screenWidth,
        if (darkMode != null) ApiObjectProperty.darkMode: darkMode,
      };
}
