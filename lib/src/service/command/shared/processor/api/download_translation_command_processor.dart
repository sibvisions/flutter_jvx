import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_download_translation_request.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';

import '../../../../../model/command/api/download_translation_command.dart';

class DownloadTranslationCommandProcessor
    with ConfigServiceMixin, ApiServiceMixin
    implements ICommandProcessor<DownloadTranslationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadTranslationCommand command) {
    String? clientId = configService.getClientId();

    if (clientId == null) {
      LOGGER.logE(pType: LOG_TYPE.COMMAND, pMessage: "Client id not found while trying to send Download translation request");
      throw Exception("Client id not found while trying to send Download translation request");
    }

    ApiDownloadTranslationRequest request = ApiDownloadTranslationRequest(clientId: clientId);
    return apiService.sendRequest(request: request);
  }
}
