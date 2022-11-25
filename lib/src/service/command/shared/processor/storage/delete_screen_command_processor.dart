import 'dart:async';

import '../../../../../../flutter_jvx.dart';
import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../../../../model/component/fl_component_model.dart';
import '../../i_command_processor.dart';

class DeleteScreenCommandProcessor implements ICommandProcessor<DeleteScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    if (command.beamBack) {
      FlutterJVx.getBeamerDelegate().beamBack();
    }
    FlComponentModel? screenModel = IUiService().getComponentByName(pComponentName: command.screenName);
    IStorageService().deleteScreen(screenName: command.screenName);
    if (screenModel != null) {
      await ILayoutService().deleteScreen(pComponentId: screenModel.id);
    }
    IUiService().closeScreen(pScreenName: command.screenName);
    IDataService().clearData(command.screenName);

    return [];
  }
}
