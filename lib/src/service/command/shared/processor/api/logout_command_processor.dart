import 'dart:io';

import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_logout_request.dart';
import 'package:flutter_client/src/model/command/api/logout_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class LogoutCommandProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<LogoutCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LogoutCommand command) async {
    ApiLogoutRequest logoutRequest = ApiLogoutRequest(
      clientId: configService.getClientId()!,
    );

    File f = File(configService.getDirectory() + "/auth.txt");

    if (f.existsSync()) {
      f.deleteSync();
    }

    return apiService.sendRequest(request: logoutRequest);
  }
}
