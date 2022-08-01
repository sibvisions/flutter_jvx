import '../api_object_property.dart';
import 'i_api_request.dart';

/// Request to change the password of the user
class ApiChangePasswordRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

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
    required this.clientId,
    required this.password,
    required this.newPassword,
    this.username,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.password: password,
        ApiObjectProperty.newPassword: newPassword,
        ApiObjectProperty.clientId: clientId,
        if (username != null) ApiObjectProperty.userName: username,
      };
}
