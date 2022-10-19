import '../../../../response/view/message/error_view_response.dart';
import 'message_view_command.dart';

/// This command will open a popup containing the provided message
class OpenServerErrorDialogCommand extends MessageViewCommand {
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

  /// True if this error is probably caused and therefore fixable by the user (e.g. invalid application)
  final bool userError;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OpenServerErrorDialogCommand({
    super.title,
    super.message,
    this.componentId,
    this.silentAbort = false,
    this.details,
    this.exceptions,
    this.userError = false,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "OpenErrorDialogCommand{componentId: $componentId, silentAbort: $silentAbort, details: $details, exceptions: $exceptions, canBeFixedInSettings: $userError, ${super.toString()}}";
  }
}
