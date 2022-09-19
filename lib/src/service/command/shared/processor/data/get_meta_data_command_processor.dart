import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_meta_data_command.dart';
import '../../../../../model/response/dal_meta_data_response.dart';
import '../../i_command_processor.dart';

class GetMetaDataCommandProcessor extends ICommandProcessor<GetMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetMetaDataCommand command) async {
    DalMetaDataResponse meta = IDataService().getMetaData(pDataProvider: command.dataProvider);

    IUiService().setMetaData(
      pSubId: command.subId,
      pDataProvider: command.dataProvider,
      pMetaData: meta,
    );

    return [];
  }
}
