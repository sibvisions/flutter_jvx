import 'package:flutter_client/src/model/api/requests/i_api_request.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';
import 'package:flutter_client/src/model/config/api/api_config.dart';

/// The interface declaring all possible requests to the mobile server.
abstract class IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes [pRequest],
  /// will throw an exception if request fails to be executed
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest});

  /// Replaces the current config
  void setApiConfig({required ApiConfig config});
}
