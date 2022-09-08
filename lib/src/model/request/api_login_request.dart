import '../../service/api/shared/api_object_property.dart';
import 'i_session_request.dart';

/// Request to login into the app
class ApiLoginRequest extends ISessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    this.createAuthKey = false,
    this.loginMode,
    this.newPassword,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.password: password,
        ApiObjectProperty.username: username,
        ApiObjectProperty.newPassword: newPassword,
        ApiObjectProperty.createAuthKey: createAuthKey,
        ApiObjectProperty.loginMode: loginMode,
      };
}
