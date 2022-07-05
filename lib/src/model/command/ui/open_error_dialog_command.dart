import 'package:flutter_client/src/model/command/ui/ui_command.dart';

/// This command will open a popup containing the provided message
class OpenErrorDialogCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This message will be displayed.
  final String message;

  /// True if this error is a timeout
  final bool isTimeout;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OpenErrorDialogCommand({
    required String reason,
    required this.message,
    this.isTimeout = false,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "OpenErrorDialogCommand: message: $message, isTimeout: $isTimeout, reason: $reason";
}
