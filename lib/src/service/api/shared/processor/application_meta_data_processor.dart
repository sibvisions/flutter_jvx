import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_app_meta_data_command.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/response/application_meta_data_response.dart';
import '../i_response_processor.dart';

class ApplicationMetaDataProcessor implements IResponseProcessor<ApplicationMetaDataResponse> {
  @override
  List<BaseCommand> processResponse(ApplicationMetaDataResponse pResponse, IApiRequest? pRequest) {
    ApplicationMetaDataResponse metaDataResponse = pResponse;

    SaveAppMetaDataCommand command =
        SaveAppMetaDataCommand(metaData: metaDataResponse, reason: "Metadata received from server");

    return [command];
  }
}
