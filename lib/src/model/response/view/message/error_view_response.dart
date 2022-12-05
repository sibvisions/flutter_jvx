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
