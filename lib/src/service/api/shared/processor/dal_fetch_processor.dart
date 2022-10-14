import '../../../../model/command/base_command.dart';
import '../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/response/dal_fetch_response.dart';
import '../i_response_processor.dart';

class DalFetchProcessor extends IResponseProcessor<DalFetchResponse> {
  @override
  List<BaseCommand> processResponse(DalFetchResponse pResponse, IApiRequest? pRequest) {
    SaveFetchDataCommand saveFetchDataCommand =
        SaveFetchDataCommand(response: pResponse, reason: "Server sent FetchData");

    return [saveFetchDataCommand];
  }
}
