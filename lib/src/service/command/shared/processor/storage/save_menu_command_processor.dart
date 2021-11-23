import 'dart:developer';

import 'package:flutter_client/src/mixin/storage_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/storage/save_menu_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SaveMenuCommandProcessor with StorageServiceMixin implements ICommandProcessor<SaveMenuCommand> {

  @override
  Future<List<BaseCommand>> processCommand(SaveMenuCommand command) async {
    log("asdas");
    storageService.saveMenu(command.menu);
    return [];
  }
}