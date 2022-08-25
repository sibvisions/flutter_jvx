import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../../util/device_info/device_info.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_startup_request.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class StartUpCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<StartupCommand> {
  @override
  Future<List<BaseCommand>> processCommand(StartupCommand command) async {
    IConfigService configService = getConfigService();

    if (command.appName != null) {
      await configService.setAppName(command.appName!);
    }
    if (command.username != null) {
      await configService.setUsername(command.username!);
    }
    if (command.password != null) {
      await configService.setPassword(command.password!);
    }

    DeviceInfo deviceInfo = DeviceInfo();
    await deviceInfo.setSystemInfo();

    ApiStartUpRequest startUpRequest = ApiStartUpRequest(
      //TODO evaluate if needed
      appMode: "full",
      applicationName: configService.getAppName()!,
      authKey: configService.getAuthCode(),
      screenHeight: configService.getPhoneSize()?.height.toInt(),
      screenWidth: configService.getPhoneSize()?.width.toInt(),
      readAheadLimit: 100,
      deviceMode: "mobile",
      username: command.username,
      password: command.password,
      langCode: getConfigService().getLanguage(),
      technology: deviceInfo.technology,
      osName: deviceInfo.osName,
      osVersion: deviceInfo.osVersion,
      appVersion: deviceInfo.appVersion,
      deviceType: deviceInfo.deviceType,
      deviceTypeModel: deviceInfo.deviceTypeModel,
      deviceId: deviceInfo.deviceId,
      forceNewSession: command.forceNewSession,
      startUpParameters: getConfigService().getStartupParameters(),
    );

    return getApiService().sendRequest(request: startUpRequest);
  }
}
