import '../../../../../flutter_jvx.dart';
import '../../../../service/api/shared/api_object_property.dart';
import 'message_view.dart';

class ErrorViewResponse extends MessageView {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If we should show this error
  final bool silentAbort;

  /// Error details from server
  final String? details;

  /// The error object.
  final List<ServerException>? exceptions;

  /// True if this error is a timeout
  final bool isTimeout;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ErrorViewResponse({
    this.silentAbort = false,
    this.details,
    required super.title,
    super.message,
    this.exceptions,
    this.isTimeout = false,
    required super.name,
    required super.originalRequest,
  });

  ErrorViewResponse.fromJson(super.json, super.originalRequest)
      : silentAbort = json[ApiObjectProperty.silentAbort] ?? false,
        details = json[ApiObjectProperty.details],
        exceptions = ServerException.fromJson(json[ApiObjectProperty.exceptions]),
        isTimeout = false,
        super.fromJson() {
    FlutterJVx.log.w(toString());
  }

  @override
  String toString() {
    return "ErrorViewResponse{messageView: ${super.toString()}, silentAbort: $silentAbort, isTimeout: $isTimeout, exceptions: $exceptions}";
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
    return "ServerException{message: $message, exception: $exception}";
  }
}
