import 'message_view.dart';

class SessionExpiredResponse extends MessageView {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SessionExpiredResponse({
    required super.title,
    super.message,
    required super.name,
  });

  SessionExpiredResponse.fromJson(super.json) : super.fromJson();
}
