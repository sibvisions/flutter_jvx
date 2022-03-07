import '../../../../model/api/response/application_meta_data_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_app_meta_data_command.dart';
import '../i_processor.dart';


class ApplicationMetaDataProcessor implements IProcessor {


  @override
  List<BaseCommand> processResponse(json) {
    ApplicationMetaDataResponse metaDataResponse = ApplicationMetaDataResponse.fromJson(json);

    SaveAppMetaDataCommand command = SaveAppMetaDataCommand(
        metaData: metaDataResponse,
        reason: "Metadata received from server"
    );

    return [command];
  }

}