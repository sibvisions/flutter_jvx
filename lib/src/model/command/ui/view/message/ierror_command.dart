/// The interface for error commands
abstract interface class ErrorCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The error object.
  Object? get error;

  /// The stack trace
  StackTrace? get stackTrace;
}
