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
    required super.originalRequest,
  });

  MessageView.fromJson({required Map<String, dynamic> pJson, required super.originalRequest})
      : title = pJson[ApiObjectProperty.title],
        message = pJson[ApiObjectProperty.message],
        super.fromJson(pJson: pJson);

  @override
  String toString() {
    return 'MessageView{title: $title, message: $message}';
  }
}
