import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/download_style_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

import '../../../../../model/api/requests/api_download_style_request.dart';

class DownloadStyleCommandProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<DownloadStyleCommand> {
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
