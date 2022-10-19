import 'ui_command.dart';

/// This command will open a popup containing the provided message
class OpenErrorDialogCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Title of the message
  final String? title;

  /// Message
  final String message;

  final Object? error;

  /// True if this error is a timeout
  final bool isTimeout;

  /// True if this error is caused and therefore fixable by the user (e.g. invalid url)
  final bool canBeFixedInSettings;

  /// True if this dialog should be dismissible
  final bool dismissible;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OpenErrorDialogCommand({
    this.title,
    required this.message,
    this.error,
    this.isTimeout = false,
    this.canBeFixedInSettings = false,
    this.dismissible = true,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'OpenErrorDialogCommand{title: $title, message: $message, error: $error, isTimeout: $isTimeout, canBeFixedInSettings: $canBeFixedInSettings, dismissible: $dismissible}';
  }
}
