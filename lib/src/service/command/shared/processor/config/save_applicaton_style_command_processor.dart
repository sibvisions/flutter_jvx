import 'package:flutter/foundation.dart';

import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_style_command.dart';
import '../../i_command_processor.dart';

class SaveApplicationStyleCommandProcessor
    with ConfigServiceGetterMixin
    implements ICommandProcessor<SaveApplicationStyleCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationStyleCommand command) {
    getConfigService().setAppStyle(command.style);
    return SynchronousFuture([]);
  }
}
