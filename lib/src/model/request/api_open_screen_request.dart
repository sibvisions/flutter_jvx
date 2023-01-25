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

import 'dart:convert';

import '../../service/api/shared/api_object_property.dart';
import 'session_request.dart';

/// Request to open a new work screen
class ApiOpenScreenRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the menuItem clicked
  final String? screenLongName;

  /// Id of the menuItem clicked
  final String? screenClassName;

  /// If the screen should only be closed manually
  final bool manualClose;

  /// Parameters to add to the request.
  final Map<String, dynamic>? parameter;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiOpenScreenRequest({
    this.screenLongName,
    this.screenClassName,
    this.parameter,
    required this.manualClose,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.componentId: screenLongName,
        ApiObjectProperty.className: screenClassName,
        ApiObjectProperty.manualClose: manualClose,
        if (parameter != null) ApiObjectProperty.parameter: jsonEncode(parameter),
      };
}
