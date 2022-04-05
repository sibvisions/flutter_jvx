import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

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
  final String eMail;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UserDataResponse({
    required this.displayName,
    required this.userName,
    required this.eMail,
    required String name
  }): super(name: name);

  UserDataResponse.fromJson({required Map<String, dynamic> json}) :
      userName = json[ApiObjectProperty.userName],
      displayName = json[ApiObjectProperty.displayName],
      eMail = json[ApiObjectProperty.eMail],
      super.fromJson(json);
}