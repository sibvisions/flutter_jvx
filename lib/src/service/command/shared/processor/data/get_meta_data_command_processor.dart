import '../../../../../../mixin/data_service_mixin.dart';
import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_meta_data_command.dart';
import '../../../../../model/response/dal_meta_data_response.dart';
import '../../i_command_processor.dart';

class GetMetaDataCommandProcessor extends ICommandProcessor<GetMetaDataCommand>
    with UiServiceGetterMixin, DataServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(GetMetaDataCommand command) async {
    DalMetaDataResponse meta = await getDataService().getMetaData(pDataProvider: command.dataProvider);

    getUiService().setMetaData(
      pSubId: command.subId,
      pDataProvider: command.dataProvider,
      pMetaData: meta,
    );

    return [];
  }
}
