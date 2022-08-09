import '../../../../util/logging/flutter_logger.dart';
import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class ErrorViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Error Title message
  final String? title;

  /// If we should show this error
  final bool silentAbort;

  /// Error details from server
  final String? details;

  /// Error message
  final String message;

  /// The error object.
  final List<ServerException>? exceptions;

  final bool isTimeout;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ErrorViewResponse({
    this.silentAbort = false,
    this.details,
    this.title,
    required this.message,
    this.exceptions,
    this.isTimeout = false,
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  ErrorViewResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : silentAbort = pJson[ApiObjectProperty.silentAbort] ?? false,
        details = pJson[ApiObjectProperty.details],
        title = pJson[ApiObjectProperty.title],
        message = pJson[ApiObjectProperty.message],
        exceptions = ServerException.fromJson(pJson[ApiObjectProperty.exceptions]),
        isTimeout = false,
        super.fromJson(pJson: pJson, originalRequest: originalRequest) {
    LOGGER.logW(pType: LOG_TYPE.COMMAND, pMessage: toString());
  }

  @override
  String toString() {
    return 'ErrorViewResponse{title: $title, silentAbort: $silentAbort, isTimeout: $isTimeout, exceptions: $exceptions}';
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

  static List<ServerException> fromJson(List<dynamic>? pJson) {
    return pJson
            ?.map(
                (element) => ServerException(element[ApiObjectProperty.message], element[ApiObjectProperty.exception]))
            .toList(growable: false) ??
        [];
  }

  @override
  String toString() {
    return 'ServerException{message: $message, exception: $exception}';
  }
}
