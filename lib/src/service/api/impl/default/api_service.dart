import '../../../../model/command/base_command.dart';
import '../../../../model/request/i_api_request.dart';
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
  IRepository? getRepository() {
    return repository;
  }

  @override
  void setRepository(IRepository pRepository) {
    repository = pRepository;
  }

  @override
  void setController(IController pController) {
    controller = pController;
  }
}
