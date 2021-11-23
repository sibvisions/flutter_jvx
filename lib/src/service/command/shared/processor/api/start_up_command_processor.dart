import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/startup_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class StartUpCommandProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<StartupCommand> {

  @override
  Future<List<BaseCommand>> processCommand(StartupCommand command) {
    String? appName = configService.getAppName();
    if(appName != null) {
      return apiService.startUp(appName);
    } else {
      throw Exception("NO APP NAME FOUND, while trying to send startUp Request");
    }
  }


}