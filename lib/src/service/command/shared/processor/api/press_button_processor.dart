import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/press_button_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class PressButtonProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<PressButtonCommand> {
  @override
  Future<List<BaseCommand>> processCommand(PressButtonCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      return apiService.pressButton(clientId, command.componentId);
    } else {
      throw Exception("Cant find Client id, while trying to send PressButton request!");
    }
  }
}
