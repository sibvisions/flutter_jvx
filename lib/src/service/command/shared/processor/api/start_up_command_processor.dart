import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_startup_request.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class StartUpCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<StartupCommand> {
  @override
  Future<List<BaseCommand>> processCommand(StartupCommand command) async {
    Map<String, dynamic> parameters = getConfigService().getStartUpParameters();

    if (command.appName != null) {
      await getConfigService().setAppName(command.appName!);
    }

    ApiStartUpRequest startUpRequest = ApiStartUpRequest(
      appMode: "full",
      deviceMode: "mobile",
      applicationName: getConfigService().getAppName(),
      username: command.username,
      password: command.password,
      authKey: getConfigService().getAuthCode(),
      langCode: getConfigService().getLanguage(),
      screenHeight: command.phoneSize?.height,
      screenWidth: command.phoneSize?.width,
      startUpParameters: parameters,
    );

    return getApiService().sendRequest(request: startUpRequest);
  }
}
