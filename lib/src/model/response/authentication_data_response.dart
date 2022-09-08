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
    required String name,
    required this.authKey,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  AuthenticationDataResponse.fromJson({
    required Map<String, dynamic> pJson,
    required Object originalRequest,
  })  : authKey = pJson[ApiObjectProperty.authKey],
        super.fromJson(originalRequest: originalRequest, pJson: pJson);
}
