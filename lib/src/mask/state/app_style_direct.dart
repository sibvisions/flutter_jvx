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

import '../../service/config/i_config_service.dart';

/// This class should be used for accessing simple "theme independent" style options.
/// Don't use it for e.g. coloring app which could depend on light/dark mode
/// If you need context dependent information, use [AppStyle] instead.
class AppStyleDirect {
  Map<String, String>? _applicationStyle;

  AppStyleDirect() {
    _applicationStyle = IConfigService().applicationStyle.value;
  }

  /// Gets the style setting by name
  String? style(String propertyName) {
    return _applicationStyle?[propertyName];
  }

  /// Gets the style setting as bool
  bool styleAsBool(String propertyName, [bool defaultValue = false]) {
    String? value = style(propertyName);

    if (value == null) {
      return defaultValue;
    }

    return bool.tryParse(value, caseSensitive: false) ?? defaultValue;
  }

}
