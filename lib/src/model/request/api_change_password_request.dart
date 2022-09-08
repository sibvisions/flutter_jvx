import '../../service/api/shared/api_object_property.dart';
import 'i_session_request.dart';

/// Request to change the password of the user
class ApiChangePasswordRequest extends ISessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Current password
  final String password;

  /// New password
  final String newPassword;

  /// Username to change the password of
  final String? username;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiChangePasswordRequest({
    required this.password,
    required this.newPassword,
    this.username,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.password: password,
        ApiObjectProperty.newPassword: newPassword,
        if (username != null) ApiObjectProperty.userName: username,
      };
}
