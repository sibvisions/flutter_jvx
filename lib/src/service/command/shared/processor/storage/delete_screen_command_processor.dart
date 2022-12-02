import 'dart:async';

import '../../../../../flutter_jvx.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../../../../model/component/fl_component_model.dart';
import '../../../../data/i_data_service.dart';
import '../../../../layout/i_layout_service.dart';
import '../../../../storage/i_storage_service.dart';
import '../../i_command_processor.dart';

class DeleteScreenCommandProcessor implements ICommandProcessor<DeleteScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    if (command.beamBack) {
      FlutterJVx.getBeamerDelegate().beamBack();
    }
    FlComponentModel? screenModel = IStorageService().getComponentByName(pComponentName: command.screenName);
    IStorageService().deleteScreen(screenName: command.screenName);
    if (screenModel != null) {
      await ILayoutService().deleteScreen(pComponentId: screenModel.id);
    }
    IDataService().clearData(command.screenName);

    return [];
  }
}
