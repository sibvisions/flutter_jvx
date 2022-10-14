import '../../../../../services.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/application_settings_response.dart';
import '../i_response_processor.dart';

class ApplicationSettingsProcessor implements IResponseProcessor<ApplicationSettingsResponse> {
  @override
  List<BaseCommand> processResponse(ApplicationSettingsResponse pResponse, ApiRequest? pRequest) {
    IConfigService().setApplicationSettings(pResponse);

    return [];
  }
}
