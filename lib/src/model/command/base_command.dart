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

///
/// Base Class for communication between services, every [BaseCommand] should always be directed at a specific Service.
///
///
abstract class BaseCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Generated ID -> DateTime.now().millisecondsSinceEpoch
  final int id;

  /// Descriptive Reason why this Command was issued.
  final String reason;

  /// If a loading progress should be displayed for this instance.
  final bool showLoading;

  /// Will be called when the command is being processed.
  FutureOr<void> Function()? beforeProcessing;

  /// Will be called when the command is done processing.
  FutureOr<void> Function()? afterProcessing;

  /// Internal callback, when all follow-up commands have been fully processed and the command therefore is done processing.
  FutureOr<void> Function()? onFinish;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  BaseCommand({
    required this.reason,
    this.beforeProcessing,
    this.afterProcessing,
    this.onFinish,
    this.showLoading = true,
  }) : id = DateTime.now().millisecondsSinceEpoch;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "ShowLoading: $showLoading | LoadingDelay: $loadingDelay | Reason: $reason";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the delay until the loading progress gets shown.
  Duration get loadingDelay => const Duration(milliseconds: 250);
}
