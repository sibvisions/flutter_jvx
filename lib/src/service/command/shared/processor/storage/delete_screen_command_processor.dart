import 'dart:async';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../i_command_processor.dart';

class DeleteScreenCommandProcessor
    with StorageServiceGetterMixin, UiServiceGetterMixin, DataServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<DeleteScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    await getStorageService().deleteScreen(screenName: command.screenName);
    getUiService().closeScreen(pScreenName: command.screenName, pBeamBack: command.beamBack);
    getDataService().clearData(getConfigService().getAppName(), command.screenName);

    return [];
  }
}
