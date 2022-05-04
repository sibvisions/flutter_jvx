import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_fetch_request.dart';
import 'package:flutter_client/src/model/command/api/fetch_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class FetchCommandProcessor extends ICommandProcessor<FetchCommand> with ApiServiceMixin, ConfigServiceMixin {
  @override
  Future<List<BaseCommand>> processCommand(FetchCommand command) async {
    ApiFetchRequest request = ApiFetchRequest(
      dataProvider: command.dataProvider,
      clientId: configService.getClientId()!,
      fromRow: command.fromRow,
      rowCount: command.rowCount,
      columnNames: command.columnNames,
      includeMetaData: command.includeMetaData,
    );

    return apiService.sendRequest(request: request);
  }
}
