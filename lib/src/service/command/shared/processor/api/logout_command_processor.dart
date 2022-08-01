import 'dart:async';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/request/api_logout_request.dart';
import '../../../../../model/command/api/logout_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class LogoutCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<LogoutCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LogoutCommand command) async {
    ApiLogoutRequest logoutRequest = ApiLogoutRequest(
      clientId: getConfigService().getClientId()!,
    );

    if (await getConfigService().getFileManager().doesFileExist(pPath: "auth.txt")) {
      getConfigService().getFileManager().deleteFile(pPath: "/auth.txt");
    }
    getConfigService().setUserInfo(null);
    unawaited(getConfigService().setAuthCode(null));

    return getApiService().sendRequest(request: logoutRequest);
  }
}
