import '../../../../../../commands.dart';
import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/response/dal_meta_data_response.dart';
import '../../i_command_processor.dart';

class GetMetaDataCommandProcessor extends ICommandProcessor<GetMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetMetaDataCommand command) async {
    bool needFetch = IDataService().getDataBook(command.dataProvider) == null;

    if (needFetch) {
      return [
        FetchCommand(
          dataProvider: command.dataProvider,
          fromRow: 0,
          rowCount: -1,
          reason: "Fetch for ${command.runtimeType}",
        )
      ];
    }

    DalMetaDataResponse meta = IDataService().getMetaData(pDataProvider: command.dataProvider);

    IUiService().setMetaData(
      pSubId: command.subId,
      pDataProvider: command.dataProvider,
      pMetaData: meta,
    );

    return [];
  }
}
