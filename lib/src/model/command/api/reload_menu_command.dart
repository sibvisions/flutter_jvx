import '../../../../commands.dart';
import '../../../../mixin/ui_service_mixin.dart';

class ReloadMenuCommand extends ApiCommand with UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? screenLongName;

  ReloadMenuCommand({
    required super.reason,
    this.screenLongName,
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
