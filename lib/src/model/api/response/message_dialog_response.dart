import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

class MessageDialogResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Displayed message
  final String message;

  /// Name of the message screen used for closing the message
  final String messageScreenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MessageDialogResponse({
    required this.message,
    required this.messageScreenName,
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  MessageDialogResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : messageScreenName = pJson[ApiObjectProperty.componentId],
        message = pJson[ApiObjectProperty.message],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
