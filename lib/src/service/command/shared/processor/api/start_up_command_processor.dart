import 'package:flutter/foundation.dart';

import '../../../../../../mixin/services.dart';
import '../../../../../../util/device_info/device_info.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_startup_request.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class StartUpCommandProcessor
    with ConfigServiceMixin, ApiServiceMixin, UiServiceMixin
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

    getUiService().getAppManager()?.onInitStartup();

    ApiStartUpRequest startUpRequest = ApiStartUpRequest(
      appMode: "full",
      applicationName: configService.getAppName()!,
      authKey: configService.getAuthCode(),
      screenHeight: configService.getPhoneSize()?.height.toInt(),
      screenWidth: configService.getPhoneSize()?.width.toInt(),
      readAheadLimit: 100,
      deviceMode:
          (kIsWeb && !getConfigService().isMobileOnly()) || getConfigService().isWebOnly() ? "mobileDesktop" : "mobile",
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
      startUpParameters: getConfigService().getStartupParameters(),
    );

    return getApiService().sendRequest(request: startUpRequest);
  }
}
