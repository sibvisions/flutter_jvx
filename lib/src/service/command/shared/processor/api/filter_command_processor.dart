import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_filter_request.dart';
import 'package:flutter_client/src/model/command/api/filter_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class FilterCommandProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<FilterCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(FilterCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      ApiFilterRequest apiFilterRequest = ApiFilterRequest(
        dataProvider: command.dataProvider,
        clientId: clientId,
        columnNames: command.columnNames,
        value: command.value,
        editorComponentId: command.editorId,
        filterCondition: command.filterCondition,
      );

      return apiService.sendRequest(request: apiFilterRequest);
    }

    return [];
  }
}
