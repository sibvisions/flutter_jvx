import '../../ui_command.dart';

class MessageViewCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Title of the message
  final String? title;

  /// Message
  final String? message;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MessageViewCommand({
    required this.title,
    this.message,
    required super.reason,
  });

  @override
  String toString() {
    return "MessageViewCommand{title: $title, message: $message, ${super.toString()}}";
  }
}
