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

import 'package:intl/intl.dart';

class VersionConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? commit;
  final String? buildDate;
  final int? buildNumber;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const VersionConfig({
    this.commit,
    this.buildDate,
    this.buildNumber,
  });

  const VersionConfig.empty() : this();

  VersionConfig.fromJson(Map<String, dynamic> json)
      : this(
          commit: json['commit'],
          buildDate: json['buildDate'] != null
              // we support milliseconds and a fixed string
              ? (json['buildDate'] is String
                  ? json['buildDate']
                  : DateFormat('dd.MM.yyyy')
                      .format(DateTime.fromMillisecondsSinceEpoch(json['buildDate'], isUtc: true)))
              : null,
          buildNumber: json['buildNumber'],
        );

  VersionConfig merge(VersionConfig? other) {
    if (other == null) return this;

    return VersionConfig(
      commit: other.commit ?? commit,
      buildDate: other.buildDate ?? buildDate,
      buildNumber: other.buildNumber ?? buildNumber,
    );
  }
}
