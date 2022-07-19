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
    String appName = getConfigService().getAppName();
    Map<String, dynamic> parameters = getConfigService().getStartUpParameters();

    ApiStartUpRequest startUpRequest = ApiStartUpRequest(
      appMode: "full",
      deviceMode: "mobile",
      applicationName: appName,
      password: command.password,
      username: command.username,
      startUpParameters: parameters,
      screenHeight: command.screenHeight,
      screenWidth: command.screenWidth,
      langCode: getConfigService().getLanguage(),
      authKey: getConfigService().getAuthCode(),
    );

    return getApiService().sendRequest(request: startUpRequest);
  }
}
