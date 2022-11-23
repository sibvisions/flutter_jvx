import '../../../../../model/command/api/mouse_clicked_command.dart';
import '../../../../../model/command/api/mouse_command.dart';
import '../../../../../model/command/api/mouse_pressed_command.dart';
import '../../../../../model/command/api/mouse_released_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_mouse_clicked_request.dart';
import '../../../../../model/request/api_mouse_pressed_request.dart';
import '../../../../../model/request/api_mouse_released_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class MouseCommandProcessor extends ICommandProcessor<MouseCommand> {
  @override
  Future<List<BaseCommand>> processCommand(MouseCommand command) async {
    if (command is MouseClickedCommand) {
      return IApiService().sendRequest(
        ApiMouseClickedRequest(
          componentName: command.componentName,
          button: command.button,
          clickCount: command.clickCount,
          x: command.x,
          y: command.y,
        ),
      );
    } else if (command is MousePressedCommand) {
      return IApiService().sendRequest(
        ApiMousePressedRequest(
          componentName: command.componentName,
          button: command.button,
          clickCount: command.clickCount,
          x: command.x,
          y: command.y,
        ),
      );
    } else if (command is MouseReleasedCommand) {
      return IApiService().sendRequest(
        ApiMouseReleasedRequest(
          componentName: command.componentName,
          button: command.button,
          clickCount: command.clickCount,
          x: command.x,
          y: command.y,
        ),
      );
    } else {
      return [];
    }
  }
}
