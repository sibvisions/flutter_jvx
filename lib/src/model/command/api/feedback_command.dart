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

import 'dart:typed_data';

import 'session_command.dart';

/// The feedback types
enum FeedbackType {
  /// User feedback
  User,
  /// Error feedback (no user interaction)
  Error,
}

/// The command for feedback.
class FeedbackCommand extends SessionCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// What type of feedback this is.
  final FeedbackType type;

  /// Feedback message (in case of a user feedback).
  final String? message;

  /// Screenshot (in case of a user feedback).
  final Uint8List? image;

  /// Custom properties.
  final Map<String, dynamic>? properties;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FeedbackCommand({
    required this.type,
    this.message,
    this.image,
    this.properties,
    required super.reason,
  })  : assert(message != null || image != null),
        super(showLoading: false);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "FeedbackCommand{type: $type, message: $message, image: ${image != null ? '[bytes: ${image?.length}]' : 'null'}, properties: $properties, ${super.toString()}}";
  }
}
