import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

import '../../../../../model/command/config/save_auth_key_command.dart';

class SaveAuthKeyCommandProcessor with ConfigServiceMixin implements ICommandProcessor<SaveAuthKeyCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAuthKeyCommand command) {
    configService.setAuthCode(command.authKey);
    return SynchronousFuture([]);
  }
}
