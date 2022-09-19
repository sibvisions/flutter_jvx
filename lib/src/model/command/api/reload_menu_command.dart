import '../../../../commands.dart';
import '../../../../services.dart';

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
      callback = () {
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
    return 'ReloadMenuCommand{${super.toString()}}';
  }
}
