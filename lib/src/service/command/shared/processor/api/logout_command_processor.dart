import 'dart:async';

import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/logout_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_logout_request.dart';
import '../../i_command_processor.dart';

class LogoutCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<LogoutCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LogoutCommand command) async {
    if (await getConfigService().getFileManager().doesFileExist(pPath: "auth.txt")) {
      getConfigService().getFileManager().deleteFile(pPath: "/auth.txt");
    }

    await getConfigService().setUserInfo(pUserInfo: null, pJson: null);
    await getConfigService().setAuthCode(null);
    await getConfigService().setPassword(null);

    return getApiService().sendRequest(request: ApiLogoutRequest());
  }
}
