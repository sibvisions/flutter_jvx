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

enum FeedbackType {
  user,
  error,
}

class FeedbackCommand extends SessionCommand {
  /// What type of feedback this is.
  final FeedbackType type;

  /// Text Feedback (in case of a user feedback).
  final String? text;

  /// UI Screenshot (in case of a user feedback).
  final Uint8List? image;

  /// Custom properties.
  final Map<String, dynamic>? properties;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FeedbackCommand({
    required this.type,
    this.text,
    this.image,
    this.properties,
    required super.reason,
  })  : assert(type != FeedbackType.user || (text != null || image != null)),
        super(showLoading: false);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'FeedbackCommand{type: $type, text: $text, image: $image, properties: $properties, ${super.toString()}}';
  }
}
