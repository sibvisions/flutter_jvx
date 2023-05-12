/*
 * Copyright 2023 SIB Visions GmbH
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
import 'package:logger/logger.dart';

import '../../flutter_ui.dart';

class LogLevelConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Defines the log level used for the general logger.
  ///
  /// See also:
  /// * [FlutterUI.log]
  final Level? general;

  /// Defines the log level used for the API logger.
  ///
  /// See also:
  /// * [FlutterUI.logAPI]
  final Level? api;

  /// Defines the log level used for the command logger.
  ///
  /// See also:
  /// * [FlutterUI.logCommand]
  final Level? command;

  /// Defines the log level used for the UI logger.
  ///
  /// See also:
  /// * [FlutterUI.logUI]
  final Level? ui;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const LogLevelConfig({
    this.general,
    this.api,
    this.command,
    this.ui,
  });

  const LogLevelConfig.empty() : this();

  LogLevelConfig.fromJson(Map<String, dynamic> json)
      : this(
          general: parseLevel(json['general']),
          api: parseLevel(json['api']),
          command: parseLevel(json['command']),
          ui: parseLevel(json['ui']),
        );

  static Level? parseLevel(String? level) =>
      level != null ? Level.values.firstWhereOrNull((e) => e.name.toLowerCase() == level.toLowerCase()) : null;

  LogLevelConfig merge(LogLevelConfig? other) {
    if (other == null) return this;

    return LogLevelConfig(
      general: other.general ?? general,
      api: other.api ?? api,
      command: other.command ?? command,
      ui: other.ui ?? ui,
    );
  }
}
