import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_delete_record_request.dart';
import 'package:flutter_client/src/model/command/api/delete_record_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class DeleteRecordCommandProcessor extends ICommandProcessor<DeleteRecordCommand> with ApiServiceMixin, ConfigServiceMixin {
  @override
  Future<List<BaseCommand>> processCommand(DeleteRecordCommand command) {
    String clientId = configService.getClientId()!;

    ApiDeleteRecordRequest deleteRecordRequest = ApiDeleteRecordRequest(
      clientId: clientId,
      dataProvider: command.dataProvider,
      selectedRow: command.selectedRow,
      fetch: command.fetch,
      filter: command.filter,
    );
    return apiService.sendRequest(request: deleteRecordRequest);
  }
}
