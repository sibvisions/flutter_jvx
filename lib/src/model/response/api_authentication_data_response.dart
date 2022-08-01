import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class ApiAuthenticationDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Auth key used for auto-login on next startup
  final String authKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiAuthenticationDataResponse({
    required String name,
    required this.authKey,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  ApiAuthenticationDataResponse.fromJson({
    required Map<String, dynamic> pJson,
    required Object originalRequest,
  })  : authKey = pJson[ApiObjectProperty.authKey],
        super.fromJson(originalRequest: originalRequest, pJson: pJson);
}
