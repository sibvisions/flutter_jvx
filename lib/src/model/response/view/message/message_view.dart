import '../../../../service/api/shared/api_object_property.dart';
import '../../api_response.dart';

class MessageView extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Title of the message
  final String title;

  /// Message
  final String? message;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MessageView({
    required this.title,
    this.message,
    required super.name,
  });

  MessageView.fromJson(super.json)
      : title = json[ApiObjectProperty.title],
        message = json[ApiObjectProperty.message],
        super.fromJson();

  @override
  String toString() {
    return "MessageView{title: $title, message: $message}";
  }
}
