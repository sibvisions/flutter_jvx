import 'package:flutter/foundation.dart';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_auth_key_command.dart';
import '../../i_command_processor.dart';

class SaveAuthKeyCommandProcessor with ConfigServiceMixin implements ICommandProcessor<SaveAuthKeyCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAuthKeyCommand command) {
    configService.setAuthCode(command.authKey);
    return SynchronousFuture([]);
  }
}
