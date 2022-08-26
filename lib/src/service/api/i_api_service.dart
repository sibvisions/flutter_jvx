import 'dart:async';

import '../../model/command/base_command.dart';
import '../../model/config/api/api_config.dart';
import '../../model/request/i_api_request.dart';
import 'shared/i_controller.dart';
import 'shared/i_repository.dart';

abstract class IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Any API Request will be sent to an [IRepository] to execute the request
  /// after which it will be processed to [BaseCommand]s in an [IController]
  Future<List<BaseCommand>> sendRequest({required IApiRequest request});

  Future<IRepository?> getRepository();

  Future<void> setRepository(IRepository pRepository);

  Future<void> setController(IController pController);

  void setApiConfig({required ApiConfig apiConfig});
}
