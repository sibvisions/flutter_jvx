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

import '../../../model/command/base_command.dart';

/// Defines the base construct of a [ICommandProcessor].
abstract class ICommandProcessor<T extends BaseCommand> {
  /// Will be called when the command is being processed.
  Future<void> beforeProcessing(T command, BaseCommand? origin) async {}

  /// Processes [command] and will return resulting commands.
  ///
  /// [origin] describes the original command that produced [command].
  Future<List<BaseCommand>> processCommand(T command, BaseCommand? origin);

  /// Will be called when the command is done processing.
  Future<void> afterProcessing(T command, BaseCommand? origin) async {}

  /// Will be called when all follow-up commands have been fully processed and the command therefore is done processing.
  Future<void> onFinish(T command) async {}
}
