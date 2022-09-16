import '../../../../commands.dart';
import '../../../../mixin/services.dart';

class ReloadMenuCommand extends ApiCommand with UiServiceMixin {
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
        if (getUiService().getMenuModel().containsScreen(screenLongName!)) {
          getUiService().sendCommand(OpenScreenCommand(
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
