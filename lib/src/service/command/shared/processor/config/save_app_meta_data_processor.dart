import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../i_command_processor.dart';

class SaveAppMetaDataProcessor with ConfigServiceMixin implements ICommandProcessor<SaveAppMetaDataCommand> {

  @override
  Future<List<BaseCommand>> processCommand(SaveAppMetaDataCommand command) async {
    configService.setClientId(command.metaData.clientId);
    configService.setVersion(command.metaData.version);
    return [];
  }
}