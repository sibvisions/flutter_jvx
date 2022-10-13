import '../model/command/ui/view/message/open_error_dialog_command.dart';

class ErrorViewException implements Exception {
  /// A message describing the exception.
  final String? message;
  final OpenErrorDialogCommand errorCommand;

  ErrorViewException(this.errorCommand, [this.message]);

  @override
  String toString() {
    return "${message != null ? "$message " : ""}${errorCommand.message}";
  }
}
