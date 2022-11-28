import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_selected_data_command.dart';
import '../../../../../model/data/subscriptions/data_record.dart';
import '../../../../data/i_data_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class GetSelectedDataCommandProcessor implements ICommandProcessor<GetSelectedDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetSelectedDataCommand command) async {
    bool needFetch = IDataService().getDataBook(command.dataProvider) == null;

    if (needFetch) {
      return [
        FetchCommand(
          dataProvider: command.dataProvider,
          fromRow: 0,
          rowCount: -1,
          reason: "Fetch for ${command.runtimeType}",
        )
      ];
    }

    // Get Data record - is null if databook has no selected row
    DataRecord? record = await IDataService().getSelectedRowData(
      pColumnNames: command.columnNames,
      pDataProvider: command.dataProvider,
    );

    IUiService().setSelectedData(
      pSubId: command.subId,
      pDataProvider: command.dataProvider,
      pDataRow: record,
    );

    return [];
  }
}
