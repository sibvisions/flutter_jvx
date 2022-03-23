import '../../../../model/api/response/dal_meta_data_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/data/save_meta_data_commnad.dart';
import '../i_processor.dart';

class DalMetaDataProcessor implements IProcessor<DalMetaDataResponse> {
  @override
  List<BaseCommand> processResponse({required DalMetaDataResponse pResponse}) {
    DalMetaDataResponse metaDataResponse = pResponse;

    SaveMetaDataCommand saveMetaDataCommand =
        SaveMetaDataCommand(response: metaDataResponse, reason: "Server sent new MetaData");

    return [saveMetaDataCommand];
  }
}
