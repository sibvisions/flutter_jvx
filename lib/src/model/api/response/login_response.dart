import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

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
    required String name
  }) : super(name: name);

  LoginResponse.fromJson({required Map<String, dynamic> pJson}) :
    mode = pJson[ApiObjectProperty.mode],
    username = pJson[ApiObjectProperty.username],
    super(name: pJson[ApiObjectProperty.name]);
}