import '../../../model/api/request/i_api_request.dart';
import '../../../model/api/response/api_response.dart';
import '../../../model/config/api/api_config.dart';

/// The interface declaring all possible requests to the mobile server.
abstract class IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the repository, has to be closed with [stop]
  Future<void> start();

  /// Stops the repository
  Future<void> stop();

  /// Returns if the repository has already been closed with [stop]
  bool isStopped();

  /// Executes [pRequest],
  /// will throw an exception if request fails to be executed
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest});

  /// Replaces the current config
  void setApiConfig({required ApiConfig config});
}
