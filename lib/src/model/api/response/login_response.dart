import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

/// Response to indicate to display the login screen
class LoginResponse extends ApiResponse {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginResponse({
    required String name
  }) : super(name: name);

  LoginResponse.fromJson({required Map<String, dynamic> pJson}) :
      super(name: pJson[ApiObjectProperty.name]);
}