import 'package:flutter_client/src/mixin/storage_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/storage/delete_screen_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class DeleteScreenProcessor with StorageServiceMixin implements ICommandProcessor<DeleteScreenCommand> {


  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    storageService.deleteScreen(screenName: command.screenName);
    return [];
  }
}