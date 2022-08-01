import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../../util/logging/flutter_logger.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_download_translation_request.dart';
import '../../i_command_processor.dart';

class DownloadTranslationCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<DownloadTranslationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadTranslationCommand command) {
    String? clientId = getConfigService().getClientId();

    if (clientId == null) {
      LOGGER.logE(
          pType: LOG_TYPE.COMMAND, pMessage: "Client id not found while trying to send Download translation request");
      throw Exception("Client id not found while trying to send Download translation request");
    }

    ApiDownloadTranslationRequest request = ApiDownloadTranslationRequest(clientId: clientId);
    return getApiService().sendRequest(request: request);
  }
}
