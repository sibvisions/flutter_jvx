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

import 'package:collection/collection.dart';

import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

enum LayoutMode {
  /// minimal layout mode (e.g. smartphone).
  Mini,

  /// small layout mode (e.g. tablet).
  Small,

  /// full layout mode (e.g. desktop).
  Full,
}

class DeviceStatusResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final LayoutMode? layoutMode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DeviceStatusResponse({
    required this.layoutMode,
    required super.name,
  });

  DeviceStatusResponse.fromJson(super.json)
      : layoutMode = json[ApiObjectProperty.layoutMode] != null
            ? LayoutMode.values.firstWhereOrNull((e) => e.name == json[ApiObjectProperty.layoutMode])
            : null,
        super.fromJson();
}
