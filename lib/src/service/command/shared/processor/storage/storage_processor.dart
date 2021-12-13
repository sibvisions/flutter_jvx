import 'package:flutter_client/src/model/command/storage/delete_screen_command.dart';
import 'package:flutter_client/src/service/command/shared/processor/storage/delete_screen_processor.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/save_components_command.dart';
import '../../../../../model/command/storage/save_menu_command.dart';
import '../../../../../model/command/storage/storage_command.dart';
import '../../i_command_processor.dart';
import 'save_components_commands_processor.dart';
import 'save_menu_command_processor.dart';

class StorageProcessor implements ICommandProcessor<StorageCommand> {

  final ICommandProcessor _saveMenuProcessor = SaveMenuCommandProcessor();
  final ICommandProcessor _saveComponentsProcessor = SaveComponentsProcessor();
  final ICommandProcessor _deleteScreenProcessor = DeleteScreenProcessor();

  @override
  Future<List<BaseCommand>> processCommand(StorageCommand command) async {

    if(command is SaveMenuCommand){
      return _saveMenuProcessor.processCommand(command);
    } else if(command is SaveComponentsCommand){
      return _saveComponentsProcessor.processCommand(command);
    } else if(command is DeleteScreenCommand){
      return _deleteScreenProcessor.processCommand(command);
    }

    return [];
  }

}