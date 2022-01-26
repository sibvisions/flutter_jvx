import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/model/command/data/save_meta_data_commnad.dart';

import '../../../../model/api/response/dal_meta_data_response.dart';
import '../../../../model/command/base_command.dart';
import '../i_processor.dart';

class DalMetaDataProcessor implements IProcessor {
  @override
  List<BaseCommand> processResponse(json) {
    DalMetaDataResponse metaDataResponse = DalMetaDataResponse.fromJson(pJson: json);

    SaveMetaDataCommand saveMetaDataCommand = SaveMetaDataCommand(response: metaDataResponse, reason: "Server sent new MetaData");

    return [saveMetaDataCommand];
  }
}
