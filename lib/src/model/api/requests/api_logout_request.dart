import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

class ApiLogoutRequest implements IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiLogoutRequest({
    required this.clientId,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
      };
}
