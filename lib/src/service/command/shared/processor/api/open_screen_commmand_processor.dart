import 'dart:developer';

import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class OpenScreenCommandProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<OpenScreenCommand> {

  @override
  Future<List<BaseCommand>> processCommand(OpenScreenCommand command) async {
    String? clientId = configService.getClientId();
    if(clientId != null) {
      log("openSreen Command processed");
      return apiService.openScreen(command.componentId, clientId);
    } else {
      throw Exception("NO CLIENT ID FOUND, while trying to send openScreen request. CommandID: " + command.id.toString());
    }
  }

}