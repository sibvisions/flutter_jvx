import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_dal_save_request.dart';
import 'package:flutter_client/src/model/command/api/dal_save_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class DalSaveCommandProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<DalSaveCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DalSaveCommand command) {
    ApiDalSaveRequest dalSaveRequest = ApiDalSaveRequest(
      clientId: configService.getClientId()!,
      dataProvider: command.dataProvider,
      onlySelected: command.onlySelected,
    );

    return apiService.sendRequest(request: dalSaveRequest);
  }
}
