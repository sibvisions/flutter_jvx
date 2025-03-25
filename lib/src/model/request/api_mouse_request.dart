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
import 'application_request.dart';

enum MouseButtonClicked { Left, Middle, Right }

abstract class ApiMouseRequest extends ApplicationRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Component name of the button clicked
  final String componentName;

  /// Which button has been pressed
  final MouseButtonClicked? button;

  /// The x coordinate where the mouse was.
  final double? x;

  /// The y coordinate where the mouse was.
  final double? y;

  /// The amount of times the mouse was clicked
  final int? clickCount;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiMouseRequest({
    required this.componentName,
    this.button,
    this.clickCount,
    this.x,
    this.y,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.componentId: componentName,
        if (button != null) ApiObjectProperty.button: button,
        if (x != null) ApiObjectProperty.x: x,
        if (y != null) ApiObjectProperty.y: y,
        if (clickCount != null) ApiObjectProperty.clickCount: clickCount,
      };
}
