import '../../../../util/logging/flutter_logger.dart';
import '../api_object_property.dart';
import 'api_response.dart';

class ErrorViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Error message
  final String message;

  /// The stacktrace of the error.
  final StackTrace? stacktrace;

  /// The error object.
  final Object? error;

  final bool isTimeout;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ErrorViewResponse({
    required this.message,
    required String name,
    required Object originalRequest,
    this.isTimeout = false,
    this.stacktrace,
    this.error,
  }) : super(name: name, originalRequest: originalRequest) {
    LOGGER.logW(
        pType: LOG_TYPE.COMMAND, pMessage: 'ErrorResponse: $message | ErrorObject $error', pStacktrace: stacktrace);
  }

  ErrorViewResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : message = pJson[ApiObjectProperty.message],
        stacktrace = null,
        error = null,
        isTimeout = false,
        super.fromJson(originalRequest: originalRequest, pJson: pJson) {
    LOGGER.logW(
        pType: LOG_TYPE.COMMAND, pMessage: 'ErrorResponse: $message | ErrorObject $error', pStacktrace: stacktrace);
  }
}
