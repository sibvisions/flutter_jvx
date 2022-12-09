import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_components_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/application_settings_response.dart';
import '../../../config/i_config_service.dart';
import '../api_response_names.dart';
import '../i_response_processor.dart';

class ApplicationSettingsProcessor implements IResponseProcessor<ApplicationSettingsResponse> {
  @override
  List<BaseCommand> processResponse(ApplicationSettingsResponse pResponse, ApiRequest? pRequest) {
    IConfigService().setApplicationSettings(pResponse);

    return [
      SaveComponentsCommand.fromJson(
        components: pResponse.components,
        reason: "${ApiResponseNames.applicationSettings} was sent",
        originRequest: pRequest,
      )
    ];
  }
}
