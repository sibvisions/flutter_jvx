import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

import '../api_object_property.dart';

/// Request to login into the app
class ApiLoginRequest implements IApiRequest {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// SessionId
  final String clientId;
  /// Username
  final String username;
  /// Password
  final String password;
  /// Either one-time-password or new password
  final String? newPassword;
  /// "password-change" or "one-time-password"
  final String? loginMode;
  /// "Remember me"
  final bool createAuthKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiLoginRequest({
    required this.username,
    required this.password,
    required this.clientId,
    this.createAuthKey = false,
    this.loginMode,
    this.newPassword,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
    ApiObjectProperty.clientId: clientId,
    ApiObjectProperty.password: password,
    ApiObjectProperty.username: username,
    ApiObjectProperty.createAuthKey : createAuthKey,
    ApiObjectProperty.loginMode : loginMode,

  };
}