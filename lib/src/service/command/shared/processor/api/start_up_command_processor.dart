import 'package:flutter_client/src/model/api/requests/api_startup_request.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
// Author: Michael Schober
class StartUpCommandProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<StartupCommand> {
  @override
  Future<List<BaseCommand>> processCommand(StartupCommand command) async {
    String appName = configService.getAppName();

    ApiStartUpRequest startUpRequest = ApiStartUpRequest(
      appMode: "full",
      deviceMode: "mobile",
      applicationName: appName,
      username: command.username,
      password: command.password
    );

    return apiService.sendRequest(request: startUpRequest);
  }
}
