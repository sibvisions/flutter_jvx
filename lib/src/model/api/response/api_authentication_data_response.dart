import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

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
  }) : super(name: name);

  ApiAuthenticationDataResponse.fromJson({required Map<String, dynamic> pJson})
      : authKey = pJson[ApiObjectProperty.authKey],
        super.fromJson(pJson);
}
