import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/get_meta_data_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class GetMetaDataCommandProcessor extends ICommandProcessor<GetMetaDataCommand> with UiServiceGetterMixin, DataServiceMixin {
  @override
  Future<List<BaseCommand>> processCommand(GetMetaDataCommand command) async {
    DalMetaDataResponse meta = await dataService.getMetaData(pDataProvider: command.dataProvider);

    getUiService().setMetaData(
      pSubId: command.subId,
      pDataProvider: command.dataProvider,
      pMetaData: meta,
    );

    return [];
  }
}
