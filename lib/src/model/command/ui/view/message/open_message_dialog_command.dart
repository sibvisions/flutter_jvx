import 'message_view_command.dart';

/// This command will open a popup containing the provided message
class OpenMessageDialogCommand extends MessageViewCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the message screen used for closing the message
  final String componentId;

  /// If the dialog should be dismissible
  final bool closable;

  /// Types of button to be displayed
  final int buttonType;

  /// Name of the ok button
  final String? okComponentId;

  /// Name of the not ok button
  final String? notOkComponentId;

  /// Name of the cancel button
  final String? cancelComponentId;

  /// Text of the ok button
  final String? okText;

  /// Text of the not ok button
  final String? notOkText;

  /// Text of the cancel button
  final String? cancelText;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OpenMessageDialogCommand({
    required super.title,
    super.message,
    required this.componentId,
    required this.closable,
    required this.buttonType,
    required this.okComponentId,
    required this.notOkComponentId,
    required this.cancelComponentId,
    this.okText,
    this.notOkText,
    this.cancelText,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'OpenMessageDialogCommand{componentId: $componentId, closable: $closable, buttonType: $buttonType, okComponentId: $okComponentId, notOkComponentId: $notOkComponentId, cancelComponentId: $cancelComponentId, okText: $okText, notOkText: $notOkText, cancelText: $cancelText, ${super.toString()}';
  }
}
