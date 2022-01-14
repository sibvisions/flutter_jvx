import 'package:flutter_client/src/service/command/shared/processor/ui/update_components_processor.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class OpenScreenCommandProcessor
    with ApiServiceMixin, ConfigServiceMixin
    implements ICommandProcessor<OpenScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenScreenCommand command) async {
    String? clientId = configService.getClientId();
    if (clientId != null) {
      UpdateComponentsProcessor.isOpenScreen = true;
      return apiService.openScreen(command.componentId, clientId);
    } else {
      throw Exception(
          "NO CLIENT ID FOUND, while trying to send openScreen request. CommandID: " + command.id.toString());
    }
  }
}
