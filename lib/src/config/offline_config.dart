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

class OfflineConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Whether data constraints sent by the server are respected while in offline mode.
  ///
  /// This should only be used for devices running Android 12+ (API 31+) as this can trigger a bug in previous SQLite versions!
  ///
  /// See also:
  /// * https://sqlite.org/src/info/86ba67afafded936
  /// * https://developer.android.com/reference/android/database/sqlite/package-summary
  /// * https://developer.android.com/tools/releases/platforms
  final bool? checkConstraints;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const OfflineConfig({
    this.checkConstraints,
  });

  const OfflineConfig.empty()
      : this(
          checkConstraints: true,
        );

  OfflineConfig.fromJson(Map<String, dynamic> json)
      : this(
          checkConstraints: json['checkConstraints'],
        );

  OfflineConfig merge(OfflineConfig? other) {
    if (other == null) return this;

    return OfflineConfig(
      checkConstraints: other.checkConstraints ?? checkConstraints,
    );
  }
}
