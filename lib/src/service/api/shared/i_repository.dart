import 'package:universal_io/io.dart';

import '../../../model/api_interaction.dart';
import '../../../model/request/api_request.dart';

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

  /// Returns all saved headers used for requests
  Map<String, String> getHeaders();

  /// Returns all saved cookies used for requests
  Set<Cookie> getCookies();

  /// Executes [pRequest],
  /// will throw an exception if request fails to be executed
  Future<ApiInteraction> sendRequest(ApiRequest pRequest);
}
