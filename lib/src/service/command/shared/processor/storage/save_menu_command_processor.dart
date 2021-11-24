import 'dart:developer';

import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/save_menu_command.dart';
import '../../i_command_processor.dart';

class SaveMenuCommandProcessor with StorageServiceMixin implements ICommandProcessor<SaveMenuCommand> {

  @override
  Future<List<BaseCommand>> processCommand(SaveMenuCommand command) async {
    log("asdas");
    storageService.saveMenu(command.menu);
    return [];
  }
}