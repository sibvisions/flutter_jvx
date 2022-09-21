import 'dart:async';

import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../i_command_processor.dart';

class DeleteScreenCommandProcessor implements ICommandProcessor<DeleteScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    IStorageService().deleteScreen(screenName: command.screenName);
    IUiService().closeScreen(pScreenName: command.screenName, pBeamBack: command.beamBack);
    IDataService().clearData(command.screenName);

    return [];
  }
}
