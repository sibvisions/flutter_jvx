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

import 'dart:async';

import '../../model/command/base_command.dart';
import '../service.dart';

/// Defines the base construct of a [ICommandService]
/// Command service is used to facilitate communication between different services.
abstract class ICommandService implements Service {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the singleton instance.
  factory ICommandService() => services<ICommandService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Process the incoming [BaseCommand].
  ///
  /// Returns true if the command was processed successfully, otherwise false.
  ///
  /// [showDialogOnError] If false, an error message dialog will be shown if an error occurs.
  /// [delayUILocking] If true, will delay the ui lock until the loading bar is shown. Overrides command specific settings if set.
  /// [showLoading] If true, will show the loading bar. Overrides command specific settings if set.
  Future<bool> sendCommand(
    BaseCommand command, {
    bool showDialogOnError = true,
    bool? delayUILocking,
    bool? showLoading,
  });

  /// Process the incoming [BaseCommand]s.
  ///
  /// This method is used to process multiple commands at once.
  /// The commands will be processed in the order they are passed.
  /// Will execute each command in sequence after the previous command has been completely processed, including its
  /// follow-up commands.
  ///
  /// Returns true if the command was processed successfully, otherwise false.
  ///
  /// [showDialogOnError] If false, an error message dialog will be shown if an error occurs.
  /// [abortOnFirstError] If true, will abort processing on the first error, otherwise the other commands will
  /// still be executed, even if an error has occurred.
  /// [delayUILocking] If true, will delay the ui lock until the loading bar is shown. Overrides command specific settings if set. But only for the first command.
  /// [showLoading] If true, will show the loading bar. Overrides command specific settings if set. But only for the first command.
  Future<bool> sendCommands(
    List<BaseCommand> commands, {
    bool showDialogOnError = true,
    bool abortOnFirstError = true,
    bool? delayUILocking,
    bool? showLoading,
  });
}
