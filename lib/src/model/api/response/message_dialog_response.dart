import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

class MessageDialogResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String message;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MessageDialogResponse({
    required this.message,
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  MessageDialogResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : message = pJson[ApiObjectProperty.message],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
