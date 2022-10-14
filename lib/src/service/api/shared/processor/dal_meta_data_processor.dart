import '../../../../model/command/base_command.dart';
import '../../../../model/command/data/save_meta_data_command.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/response/dal_meta_data_response.dart';
import '../i_response_processor.dart';

class DalMetaDataProcessor implements IResponseProcessor<DalMetaDataResponse> {
  @override
  List<BaseCommand> processResponse(DalMetaDataResponse pResponse, IApiRequest? pRequest) {
    DalMetaDataResponse metaDataResponse = pResponse;

    SaveMetaDataCommand saveMetaDataCommand =
        SaveMetaDataCommand(response: metaDataResponse, reason: "Server sent new MetaData");

    return [saveMetaDataCommand];
  }
}
