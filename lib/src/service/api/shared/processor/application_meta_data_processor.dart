import '../../../../model/api/response/application_meta_data_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_app_meta_data_command.dart';
import '../i_processor.dart';


class ApplicationMetaDataProcessor implements IProcessor<ApplicationMetaDataResponse> {
  @override
  List<BaseCommand> processResponse({required ApplicationMetaDataResponse pResponse}) {
    ApplicationMetaDataResponse metaDataResponse = pResponse;

    SaveAppMetaDataCommand command = SaveAppMetaDataCommand(
        metaData: metaDataResponse,
        reason: "Metadata received from server"
    );

    return [command];
  }

}