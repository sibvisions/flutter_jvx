import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

import '../../../../../model/command/config/save_application_style_command.dart';

class SaveApplicationStyleCommandProcessor with ConfigServiceMixin implements ICommandProcessor<SaveApplicationStyleCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationStyleCommand command) {
    configService.setAppStyle(command.style);
    return SynchronousFuture([]);
  }
}
