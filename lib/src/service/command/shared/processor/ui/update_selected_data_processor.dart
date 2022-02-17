import '../../../../../mixin/ui_service_getter_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_selected_data_command.dart';
import '../../i_command_processor.dart';

class UpdateSelectedDataProcessor with UiServiceGetterMixin implements ICommandProcessor<UpdateSelectedDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UpdateSelectedDataCommand command) async {
    getUiService().setSelectedData(
        pDataProvider: command.dataProvider,
        pComponentId: command.componentId,
        data: command.data,
        pColumnName: command.columnName);

    return [];
  }
}
