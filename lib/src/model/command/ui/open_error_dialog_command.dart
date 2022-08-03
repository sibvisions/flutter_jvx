import 'ui_command.dart';

/// This command will open a popup containing the provided message
class OpenErrorDialogCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This message will be displayed.
  final String message;

  /// True if this error is a timeout
  final bool isTimeout;

  /// True if this error is caused and therefore fixable by the user (e.g. invalid url)
  final bool canBeFixedInSettings;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OpenErrorDialogCommand({
    required String reason,
    required this.message,
    this.isTimeout = false,
    this.canBeFixedInSettings = false,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "OpenErrorDialogCommand: message: $message, isTimeout: $isTimeout, reason: $reason";
}
