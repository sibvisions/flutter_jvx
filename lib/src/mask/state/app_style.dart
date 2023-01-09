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

import 'package:flutter/material.dart';

import '../../model/response/application_settings_response.dart';

class AppStyle extends InheritedWidget {
  final Map<String, String> applicationStyle;

  final ApplicationSettingsResponse applicationSettings;

  const AppStyle({
    super.key,
    required this.applicationStyle,
    required this.applicationSettings,
    required super.child,
  });

  /// The closest instance of this class that encloses the given context.
  static AppStyle of(BuildContext context) {
    final AppStyle? result = maybeOf(context);
    assert(result != null, "No AppStyle found in context");
    return result!;
  }

  /// The closest instance of this class that encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static AppStyle? maybeOf(BuildContext? context) {
    return context?.dependOnInheritedWidgetOfExactType<AppStyle>();
  }

  @override
  bool updateShouldNotify(covariant AppStyle oldWidget) =>
      applicationStyle != oldWidget.applicationStyle && applicationSettings != oldWidget.applicationSettings;
}
