

import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/save_user_data_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SaveUserDataCommandProcessor with ConfigServiceMixin implements ICommandProcessor<SaveUserDataCommand> {

  @override
  Future<List<BaseCommand>> processCommand(SaveUserDataCommand command) async {

    configService.setUserInfo(command.userInfo);

    return [];
  }

}