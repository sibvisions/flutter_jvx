import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_fetch_request.dart';
import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class FetchCommandProcessor extends ICommandProcessor<FetchCommand>
    with ApiServiceGetterMixin, ConfigServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(FetchCommand command) async {
    ApiFetchRequest request = ApiFetchRequest(
      dataProvider: command.dataProvider,
      clientId: getConfigService().getClientId()!,
      fromRow: command.fromRow,
      rowCount: command.rowCount,
      columnNames: command.columnNames,
      includeMetaData: command.includeMetaData,
    );

    return getApiService().sendRequest(request: request);
  }
}
