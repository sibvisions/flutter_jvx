import '../../../service/ui/i_ui_service.dart';
import 'api_command.dart';
import 'open_screen_command.dart';

class ReloadMenuCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? screenLongName;

  final String? screenClassName;

  ReloadMenuCommand({
    required super.reason,
    this.screenLongName,
    this.screenClassName,
  }) {
    if (screenLongName != null) {
      onFinish = () {
        if (IUiService().getMenuModel().containsScreen(screenLongName!)) {
          IUiService().sendCommand(OpenScreenCommand(
            screenLongName: screenLongName!,
            reason: reason,
          ));
        }
      };
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "ReloadMenuCommand{${super.toString()}}";
  }
}
