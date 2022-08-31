import '../../../../response/view/message/error_view_response.dart';
import 'message_view_command.dart';

/// This command will open a popup containing the provided message
class OpenErrorDialogCommand extends MessageViewCommand {
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

  /// True if this error is caused and therefore fixable by the user (e.g. invalid url)
  final bool canBeFixedInSettings;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OpenErrorDialogCommand({
    super.title = "",
    super.message,
    this.silentAbort = false,
    this.details,
    this.exceptions,
    required super.reason,
    this.isTimeout = false,
    this.canBeFixedInSettings = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "OpenErrorDialogCommand: ${super.toString()}, isTimeout: $isTimeout, reason: $reason";
}
