import 'dart:async';

import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/data_service_mixin.dart';

import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../i_command_processor.dart';

class DeleteScreenProcessor
    with StorageServiceGetterMixin, UiServiceGetterMixin, DataServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<DeleteScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    await getStorageService().deleteScreen(screenName: command.screenName);
    getUiService().closeScreen(pScreenName: command.screenName);
    getDataService().clearData(getConfigService().getAppName(), command.screenName);

    return [];
  }
}
