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

import 'dart:convert';
import 'dart:typed_data';

import '../command/api/feedback_command.dart';
import 'session_request.dart';

/// Sends feedback (errors) to the server
class ApiFeedbackRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// What type of feedback this is.
  final FeedbackType type;

  /// Text Feedback (in case of a user feedback).
  final String? message;

  /// UI Screenshot (in case of a user feedback).
  final Uint8List? image;

  /// Custom properties.
  final Map<String, dynamic>? properties;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFeedbackRequest({
    required this.type,
    this.message,
    this.image,
    this.properties,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        "name": "feedback.${type.name}",
        if (message != null) "message": message,
        if (image != null) "image": base64Encode(image!),
        ...?properties
        //maybe we should check value types because not all objects can be converted to json
        //...?properties?.map((key, value) => MapEntry(key.toString(), value.toString())),
      };
}
