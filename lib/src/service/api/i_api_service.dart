import 'package:flutter_client/src/model/api/requests/i_api_request.dart';
import 'package:flutter_client/src/service/api/shared/i_controller.dart';
import 'package:flutter_client/src/service/api/shared/i_repository.dart';

import '../../model/command/base_command.dart';

abstract class IApiService {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Any API Request will be sent to an [IRepository] to execute the request
  /// after which it will be processed to [BaseCommand]s in an [IController]
  Future<List<BaseCommand>> sendRequest({required IApiRequest request});
}
