import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_logout_request.dart';
import '../../../../../model/command/api/logout_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class LogoutCommandProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<LogoutCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LogoutCommand command) async {
    ApiLogoutRequest logoutRequest = ApiLogoutRequest(
      clientId: configService.getClientId()!,
    );

    if (await configService.getFileManager().doesFileExist(pPath: "auth.txt")) {
      configService.getFileManager().deleteFile(pPath: "/auth.txt");
    }
    configService.setUserInfo(null);
    configService.setAuthCode(null);

    return apiService.sendRequest(request: logoutRequest);
  }
}
