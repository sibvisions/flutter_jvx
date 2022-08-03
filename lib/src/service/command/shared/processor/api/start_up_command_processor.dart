import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_startup_request.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class StartUpCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<StartupCommand> {
  @override
  Future<List<BaseCommand>> processCommand(StartupCommand command) async {
    if (command.appName != null) {
      await getConfigService().setAppName(command.appName!);
    }
    if (command.username != null) {
      await getConfigService().setUsername(command.username!);
    }
    if (command.password != null) {
      await getConfigService().setPassword(command.password!);
    }

    ApiStartUpRequest startUpRequest = ApiStartUpRequest(
      //TODO evaluate if needed
      appMode: "full",
      deviceMode: "mobile",
      applicationName: getConfigService().getAppName()!,
      username: command.username,
      password: command.password,
      authKey: getConfigService().getAuthCode(),
      langCode: getConfigService().getLanguage(),
      screenHeight: command.phoneSize?.height ?? getConfigService().getPhoneSize()?.height,
      screenWidth: command.phoneSize?.width ?? getConfigService().getPhoneSize()?.width,
      startUpParameters: getConfigService().getStartUpParameters(),
    );

    return getApiService().sendRequest(request: startUpRequest);
  }
}
