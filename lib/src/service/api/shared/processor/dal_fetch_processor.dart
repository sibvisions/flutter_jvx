import 'package:flutter_client/src/model/command/data/save_fetch_data_command.dart';

import '../../../../model/api/response/dal_fetch_response.dart';
import '../../../../model/command/base_command.dart';
import '../i_processor.dart';

class DalFetchProcessor extends IProcessor {
  @override
  List<BaseCommand> processResponse(json) {
    DalFetchResponse res = DalFetchResponse.fromJson(json);

    SaveFetchDataCommand saveFetchDataCommand = SaveFetchDataCommand(response: res, reason: "Server sent FetchData");

    return [saveFetchDataCommand];
  }
}
