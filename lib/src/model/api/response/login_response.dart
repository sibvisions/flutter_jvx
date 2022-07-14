import '../api_object_property.dart';
import 'api_response.dart';

/// Response to indicate to display the login screen
class LoginResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? username;

  final String mode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginResponse({
    required this.username,
    required this.mode,
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  LoginResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : mode = pJson[ApiObjectProperty.mode],
        username = pJson[ApiObjectProperty.username],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
