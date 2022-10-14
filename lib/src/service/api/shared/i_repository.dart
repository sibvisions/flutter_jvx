import '../../../model/api_interaction.dart';
import '../../../model/request/i_api_request.dart';

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
  Future<ApiInteraction> sendRequest(IApiRequest pRequest);
}
