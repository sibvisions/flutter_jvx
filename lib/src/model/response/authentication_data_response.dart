import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class AuthenticationDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Auth key used for auto-login on next startup
  final String authKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AuthenticationDataResponse({
    required super.name,
    required this.authKey,
  });

  AuthenticationDataResponse.fromJson(super.json)
      : authKey = json[ApiObjectProperty.authKey],
        super.fromJson();
}
