import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/command_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/api/go_offline_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class GoOfflineCommandProcessor
    with
        ConfigServiceGetterMixin,
        UiServiceGetterMixin,
        ApiServiceGetterMixin,
        DataServiceGetterMixin,
        StorageServiceGetterMixin,
        CommandServiceGetterMixin
    implements ICommandProcessor<GoOfflineCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(GoOfflineCommand command) async {
    return [];
  }
}
