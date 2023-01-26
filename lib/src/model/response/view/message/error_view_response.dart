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

import '../../../../flutter_ui.dart';
import '../../../../service/api/shared/api_object_property.dart';
import 'message_view.dart';

class ErrorViewResponse extends MessageView {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the message screen used for closing the dialog
  final String? componentId;

  /// If we should show this error
  final bool silentAbort;

  /// Error details from server
  final String? details;

  /// The error object.
  final List<ServerException>? exceptions;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ErrorViewResponse({
    this.componentId,
    this.silentAbort = false,
    this.details,
    required super.title,
    super.message,
    this.exceptions,
    required super.name,
  });

  ErrorViewResponse.fromJson(super.json)
      : componentId = json[ApiObjectProperty.componentId],
        silentAbort = json[ApiObjectProperty.silentAbort] ?? false,
        details = json[ApiObjectProperty.details],
        exceptions = ServerException.fromJson(json[ApiObjectProperty.exceptions]),
        super.fromJson() {
    FlutterUI.log.w(toString());
  }

  @override
  String toString() {
    return "ErrorViewResponse{messageView: ${super.toString()}, componentId: $componentId, silentAbort: $silentAbort, exceptions: $exceptions}";
  }
}

class ServerException {
  /// Error message
  final String message;

  /// Error stacktrace
  final String? exception;

  ServerException(this.message, this.exception);

  ServerException.fromException(Exception error, [StackTrace? stackTrace])
      : this(error.toString(), stackTrace?.toString());

  static List<ServerException> fromJson(List<dynamic>? json) {
    return json
            ?.map(
                (element) => ServerException(element[ApiObjectProperty.message], element[ApiObjectProperty.exception]))
            .toList(growable: false) ??
        [];
  }

  @override
  String toString() {
    return "ServerException{message: $message, exception: $exception}";
  }
}
