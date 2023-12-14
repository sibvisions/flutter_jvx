abstract class ErrorCommand {
  /// The error object.
  Object? get error;

  /// The stack trace
  StackTrace? get stackTrace;
}
