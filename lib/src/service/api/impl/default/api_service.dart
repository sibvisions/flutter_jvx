import 'package:flutter/foundation.dart';

import '../../../../model/request/i_api_request.dart';
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
  IRepository? repository;

  /// Processes responses into commands
  IController? controller;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a Instance where [repository] and [controller] are null
  /// and need to be set before any request can be sent.
  ApiService();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> sendRequest({required IApiRequest request}) {
    if (repository == null) throw Exception("Repository not initialized");
    if (controller == null) throw Exception("Controller not initialized");
    return repository!.sendRequest(pRequest: request).then((value) => controller!.processResponse(responses: value));
  }

  @override
  Future<IRepository?> getRepository() {
    return SynchronousFuture(repository);
  }

  @override
  Future<void> setRepository(IRepository pRepository) async {
    repository = pRepository;
  }

  @override
  Future<void> setController(IController pController) async {
    controller = pController;
  }

  @override
  void setApiConfig({required ApiConfig apiConfig}) {
    if (repository == null) throw Exception("Repository not initialized");
    repository!.setApiConfig(config: apiConfig);
  }
}
