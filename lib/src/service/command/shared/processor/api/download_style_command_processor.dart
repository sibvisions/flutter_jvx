import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_download_style_request.dart';
import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../i_command_processor.dart';

class DownloadStyleCommandProcessor
    with ConfigServiceMixin, ApiServiceMixin
    implements ICommandProcessor<DownloadStyleCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadStyleCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId == null) {
      return [OpenErrorDialogCommand(reason: "Could not read clientId", message: "Could not read clientId")];
    }

    ApiDownloadStyleRequest downloadTranslationRequest = ApiDownloadStyleRequest(clientId: clientId);
    return apiService.sendRequest(request: downloadTranslationRequest);
  }
}
