import '../../../../model/command/data/save_fetch_data_command.dart';

import '../../../../model/api/response/dal_fetch_response.dart';
import '../../../../model/command/base_command.dart';
import '../i_processor.dart';

class DalFetchProcessor extends IProcessor<DalFetchResponse> {

  @override
  List<BaseCommand> processResponse({required DalFetchResponse pResponse}) {
    DalFetchResponse res = pResponse;

    SaveFetchDataCommand saveFetchDataCommand = SaveFetchDataCommand(response: res, reason: "Server sent FetchData");

    return [saveFetchDataCommand];
  }
}
