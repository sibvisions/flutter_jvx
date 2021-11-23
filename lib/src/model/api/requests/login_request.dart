import 'package:flutter_client/src/model/api/api_object_property.dart';

class LoginRequest {

  final String username;
  final String password;
  final String clientId;

  LoginRequest({
    required this.username,
    required this.password,
    required this.clientId
  });


  Map<String, dynamic> toJson() => {
    ApiObjectProperty.clientId: clientId,
    ApiObjectProperty.password: password,
    ApiObjectProperty.username: username,
  };
}