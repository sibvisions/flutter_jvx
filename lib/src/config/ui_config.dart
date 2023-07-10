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

import '../mask/setting/settings_page.dart';
import '../model/response/application_meta_data_response.dart';

class UiConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Whether the language switch should be visible in [SettingsPage].
  final bool? hideLanguageSetting;

  /// Whether the picture size switch should be visible in [SettingsPage].
  final bool? hidePictureSizeSetting;

  /// Whether the [ThemeMode] switch should be visible in [SettingsPage].
  final bool? hideThemeSetting;

  /// Whether a "Remember me?" checkbox is shown in the Login view.
  ///
  /// This can be overridden by the [ApplicationMetaDataResponse].
  ///
  /// See also:
  /// * [ApplicationMetaDataResponse.rememberMeEnabled]
  final bool? showRememberMe;

  /// Whether the "Remember me?" checkbox is checked by default.
  final bool? rememberMeChecked;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const UiConfig({
    this.hideLanguageSetting,
    this.hidePictureSizeSetting,
    this.hideThemeSetting,
    this.showRememberMe,
    this.rememberMeChecked,
  });

  const UiConfig.defaults()
      : this(
          hideLanguageSetting: false,
          hidePictureSizeSetting: false,
          hideThemeSetting: false,
          showRememberMe: false,
          rememberMeChecked: false,
        );

  UiConfig.fromJson(Map<String, dynamic> json)
      : this(
          hideLanguageSetting: json['hideLanguageSetting'],
          hidePictureSizeSetting: json['hidePictureSizeSetting'],
          hideThemeSetting: json['hideThemeSetting'],
          showRememberMe: json['showRememberMe'],
          rememberMeChecked: json['rememberMeChecked'],
        );

  UiConfig merge(UiConfig? other) {
    if (other == null) return this;

    return UiConfig(
      hideLanguageSetting: other.hideLanguageSetting ?? hideLanguageSetting,
      hidePictureSizeSetting: other.hidePictureSizeSetting ?? hidePictureSizeSetting,
      hideThemeSetting: other.hideThemeSetting ?? hideThemeSetting,
      showRememberMe: other.showRememberMe ?? showRememberMe,
      rememberMeChecked: other.rememberMeChecked ?? rememberMeChecked,
    );
  }
}
