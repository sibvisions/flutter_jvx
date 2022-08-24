import '../../../../service/api/shared/api_object_property.dart';
import 'message_view.dart';

class MessageDialogResponse extends MessageView {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the message screen used for closing the message
  final String messageScreenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MessageDialogResponse({
    required super.title,
    required super.message,
    required this.messageScreenName,
    required super.name,
    required super.originalRequest,
  });

  MessageDialogResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : messageScreenName = pJson[ApiObjectProperty.componentId],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
