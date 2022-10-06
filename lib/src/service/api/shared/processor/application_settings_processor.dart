import '../../../../../services.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/response/application_settings_response.dart';
import '../i_response_processor.dart';

class ApplicationSettingsProcessor implements IResponseProcessor<ApplicationSettingsResponse> {
  @override
  List<BaseCommand> processResponse({required ApplicationSettingsResponse pResponse}) {
    IConfigService().setApplicationSettings(pResponse);

    return [];
  }
}
