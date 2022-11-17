import '../../service/api/shared/api_object_property.dart';
import '../command/api/login_command.dart';
import 'session_request.dart';

/// Request to login into the app
class ApiLoginRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// See [LoginMode] class
  final LoginMode loginMode;

  /// Username
  final String username;

  /// Password
  final String password;

  /// Either one-time-password or new password
  final String? newPassword;

  /// "Remember me"
  final bool createAuthKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiLoginRequest({
    this.loginMode = LoginMode.Manual,
    required this.username,
    required this.password,
    this.createAuthKey = false,
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
        ApiObjectProperty.loginMode: loginMode.name,
      };
}
