import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/filter_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_filter_request.dart';
import '../../i_command_processor.dart';

class FilterCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<FilterCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(FilterCommand command) async {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      ApiFilterRequest apiFilterRequest = ApiFilterRequest(
        dataProvider: command.dataProvider,
        clientId: clientId,
        columnNames: command.columnNames,
        value: command.value,
        editorComponentId: command.editorId,
        filter: command.filter,
        filterCondition: command.filterCondition,
      );

      return getApiService().sendRequest(request: apiFilterRequest);
    }

    return [];
  }
}
