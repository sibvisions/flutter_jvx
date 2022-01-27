import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/update_selected_data_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class UpdateSelectedDataProcessor with UiServiceGetterMixin implements ICommandProcessor<UpdateSelectedDataCommand> {

  @override
  Future<List<BaseCommand>> processCommand(UpdateSelectedDataCommand command) async {

    getUiService().setSelectedData(
        pDataProvider: command.dataProvider,
        pComponentId: command.componentId,
        data: command.data
    );

    return [];
  }
}