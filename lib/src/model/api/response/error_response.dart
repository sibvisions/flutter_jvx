import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';

class ErrorResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Error message
  final String message;

  /// The stacktrace of the error.
  final StackTrace? stacktrace;

  /// The error object.
  final Object? error;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ErrorResponse({
    required this.message,
    required String name,
    this.stacktrace,
    this.error,
  }) : super(name: name) {
    LOGGER.logI(
        pType: LOG_TYPE.COMMAND, pMessage: 'ErrorResponse: $message | ErrorObject $error', pStacktrace: stacktrace);
  }

  ErrorResponse.fromJson({required Map<String, dynamic> pJson})
      : message = pJson[ApiObjectProperty.message],
        stacktrace = null,
        error = null,
        super.fromJson(pJson) {
    LOGGER.logI(
        pType: LOG_TYPE.COMMAND, pMessage: 'ErrorResponse: $message | ErrorObject $error', pStacktrace: stacktrace);
  }
}
