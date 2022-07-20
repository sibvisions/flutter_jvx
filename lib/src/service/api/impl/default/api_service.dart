import 'package:flutter/foundation.dart';

import '../../../../model/api/requests/i_api_request.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/config/api/api_config.dart';
import '../../i_api_service.dart';
import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';

///
/// Will execute all actions on the main Isolate
///
class ApiService implements IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes remote requests
  late IRepository repository;

  /// Processes responses into commands
  late IController controller;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Standard constructor
  ApiService({required this.repository, required this.controller});

  /// Initializes a Instance where [repository] and [controller] are null
  /// and need to be set before any request can be sent.
  ApiService.empty();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> sendRequest({required IApiRequest request}) {
    return repository.sendRequest(pRequest: request).then((value) => controller.processResponse(responses: value));
  }

  @override
  Future<IRepository> getRepository() {
    return SynchronousFuture(repository);
  }

  @override
  Future<void> setRepository(IRepository pRepository) async {
    repository = pRepository;
  }

  @override
  void setApiConfig({required ApiConfig apiConfig}) {
    repository.setApiConfig(config: apiConfig);
  }
}
