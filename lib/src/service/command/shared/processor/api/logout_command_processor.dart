import 'dart:async';

import '../../../../../model/command/api/logout_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_logout_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

class LogoutCommandProcessor implements ICommandProcessor<LogoutCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LogoutCommand command) async {
    if (await IConfigService().getFileManager().doesFileExist(pPath: "auth.txt")) {
      IConfigService().getFileManager().deleteFile(pPath: "/auth.txt");
    }

    await IConfigService().setUserInfo(pUserInfo: null, pJson: null);
    await IConfigService().setAuthCode(null);
    await IConfigService().setPassword(null);

    return IApiService().sendRequest(ApiLogoutRequest());
  }
}
