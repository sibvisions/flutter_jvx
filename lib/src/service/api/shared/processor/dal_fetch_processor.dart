import '../../../../model/response/dal_fetch_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/data/save_fetch_data_command.dart';
import '../i_response_processor.dart';

class DalFetchProcessor extends IResponseProcessor<DalFetchResponse> {
  @override
  List<BaseCommand> processResponse({required DalFetchResponse pResponse}) {
    SaveFetchDataCommand saveFetchDataCommand =
        SaveFetchDataCommand(response: pResponse, reason: "Server sent FetchData");

    return [saveFetchDataCommand];
  }
}
