import 'dart:async';

import '../../../../../../mixin/services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../i_command_processor.dart';

class DeleteScreenCommandProcessor
    with StorageServiceMixin, UiServiceMixin, DataServiceMixin
    implements ICommandProcessor<DeleteScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    await getStorageService().deleteScreen(screenName: command.screenName);
    getUiService().closeScreen(pScreenName: command.screenName, pBeamBack: command.beamBack);
    getDataService().clearData(command.screenName);

    return [];
  }
}
