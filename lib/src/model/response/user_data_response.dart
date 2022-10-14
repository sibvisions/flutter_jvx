import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

/// Contains all user specific data
class UserDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Unique name
  final String userName;

  /// Name to display
  final String displayName;

  /// Email of the user
  final String? eMail;

  /// Profile image of the user
  final String? profileImage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UserDataResponse({
    required this.displayName,
    required this.userName,
    required this.eMail,
    required this.profileImage,
    required super.name,
    required super.originalRequest,
  });

  UserDataResponse.fromJson(super.json, super.originalRequest)
      : userName = json[ApiObjectProperty.userName],
        displayName = json[ApiObjectProperty.displayName],
        eMail = json[ApiObjectProperty.eMail],
        profileImage = json[ApiObjectProperty.profileImage],
        super.fromJson();
}
