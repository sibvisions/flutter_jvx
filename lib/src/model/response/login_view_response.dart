import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

/// Response to indicate to display the login screen
class LoginViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? username;

  final String mode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginViewResponse({
    required this.username,
    required this.mode,
    required super.name,
  });

  LoginViewResponse.fromJson(super.json)
      : mode = json[ApiObjectProperty.mode],
        username = json[ApiObjectProperty.username],
        super.fromJson();
}
