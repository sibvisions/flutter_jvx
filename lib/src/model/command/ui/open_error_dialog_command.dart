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

import 'ui_command.dart';
import 'view/message/ierror_command.dart';

/// This command will open a popup containing the provided message
class OpenErrorDialogCommand extends UiCommand implements ErrorCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Title of the message
  final String? title;

  /// Message
  final String message;

  /// The error
  @override
  final Object? error;

  /// The stack trace
  @override
  final StackTrace? stackTrace;

  /// True if this error is a timeout
  final bool isTimeout;

  /// True if this dialog should be dismissible
  final bool dismissible;

  /// True if this dialog should be silently ignored.
  final bool silentAbort;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OpenErrorDialogCommand({
    required this.message,
    this.error,
    this.title,
    this.stackTrace,
    this.isTimeout = false,
    this.dismissible = true,
    this.silentAbort = false,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "OpenErrorDialogCommand{title: $title, message: $message, error: $error, isTimeout: $isTimeout, "
           "stackTrace: $stackTrace, dismissible: $dismissible, silentAbort: $silentAbort, ${super.toString()}";
  }
}
