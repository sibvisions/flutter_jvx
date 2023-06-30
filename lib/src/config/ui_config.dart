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

import '../model/response/application_meta_data_response.dart';

class UiConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    this.showRememberMe,
    this.rememberMeChecked,
  });

  const UiConfig.defaults()
      : this(
          showRememberMe: false,
          rememberMeChecked: false,
        );

  UiConfig.fromJson(Map<String, dynamic> json)
      : this(
          showRememberMe: json['showRememberMe'],
          rememberMeChecked: json['rememberMeChecked'],
        );

  UiConfig merge(UiConfig? other) {
    if (other == null) return this;

    return UiConfig(
      showRememberMe: other.showRememberMe ?? showRememberMe,
      rememberMeChecked: other.rememberMeChecked ?? rememberMeChecked,
    );
  }
}
