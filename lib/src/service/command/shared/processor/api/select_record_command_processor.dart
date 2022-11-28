import '../../../../../model/command/api/select_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/change_selected_row_command.dart';
import '../../../../../model/request/api_select_record_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

class SelectRecordCommandProcessor implements ICommandProcessor<SelectRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SelectRecordCommand command) async {
    if (IConfigService().isOffline()) {
      return [
        ChangeSelectedRowCommand(
            dataProvider: command.dataProvider, newSelectedRow: command.selectedRecord, reason: command.reason)
      ];
    }

    return IApiService().sendRequest(
      ApiSelectRecordRequest(
        dataProvider: command.dataProvider,
        selectedRow: command.selectedRecord,
        fetch: command.fetch,
        filter: command.filter,
        reload: command.reload,
      ),
    );
  }
}
