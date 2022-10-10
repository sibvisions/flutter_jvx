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
    required super.originalRequest,
  });

  SessionExpiredResponse.fromJson({required super.json, required super.originalRequest}) : super.fromJson();
}
