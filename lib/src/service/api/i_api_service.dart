import '../../model/command/base_command.dart';
import '../../model/request/i_api_request.dart';
import '../service.dart';
import 'shared/i_controller.dart';
import 'shared/i_repository.dart';

abstract class IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory IApiService() => services<IApiService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Any API Request will be sent to an [IRepository] to execute the request
  /// after which it will be processed to [BaseCommand]s in an [IController]
  Future<List<BaseCommand>> sendRequest(IApiRequest request);

  IRepository? getRepository();

  void setRepository(IRepository pRepository);

  void setController(IController pController);
}
