import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/save_menu_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SaveMenuCommandProcessor with UiServiceGetterMixin implements ICommandProcessor<SaveMenuCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveMenuCommand command) {
    getUiService().setMenuModel(pMenuModel: command.menuModel);
    return SynchronousFuture([]);
  }
}
