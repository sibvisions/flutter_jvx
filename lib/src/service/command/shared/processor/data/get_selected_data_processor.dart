import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_selected_data.dart';
import '../../../../../model/command/ui/update_selected_data_command.dart';
import '../../i_command_processor.dart';

class GetSelectedDataProcessor with DataServiceMixin implements ICommandProcessor<GetSelectedDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetSelectedDataCommand command) async {
    dynamic data =
        await dataService.getSelectedDataColumn(pColumnName: command.columnName, pDataProvider: command.dataProvider);

    UpdateSelectedDataCommand updateSelectedDataCommand = UpdateSelectedDataCommand(
        reason: "${command.componentId} requested data from ${command.dataProvider}",
        componentId: command.componentId,
        data: data,
        dataProvider: command.dataProvider);

    return [updateSelectedDataCommand];
  }
}
