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

import '../base_command.dart';
import '../queue_command.dart';
import 'ui_command.dart';

typedef CommandCallback = FutureOr<List<BaseCommand>> Function();

/// Command to execute a custom function as a command.
class FunctionCommand extends UiCommand {
  final CommandCallback commandCallback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FunctionCommand(
    this.commandCallback, {
    super.showLoading = true,
    super.delayUILocking = false,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "FunctionCommand{${super.toString()}}";
  }
}

/// Command to execute a custom function as a command.
class QueuedFunctionCommand extends FunctionCommand implements QueueCommand {
  QueuedFunctionCommand(
    super.commandCallback, {
    super.showLoading = true,
    super.delayUILocking = false,
    required super.reason,
  });
}
