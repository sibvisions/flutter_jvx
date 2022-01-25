import '../../../../model/api/response/dal_meta_data_response.dart';
import '../../../../model/command/base_command.dart';
import '../i_processor.dart';

class DalMetaDataProcessor implements IProcessor {
  @override
  List<BaseCommand> processResponse(json) {
    DalMetaDataResponse metaDataResponse = DalMetaDataResponse.fromJson(pJson: json);

    return [];
  }
}
