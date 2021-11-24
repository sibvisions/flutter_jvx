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
    String? appName = configService.getAppName();
    if(appName != null) {
      return apiService.startUp(appName);
    } else {
      throw Exception("NO APP NAME FOUND, while trying to send startUp Request");
    }
  }


}