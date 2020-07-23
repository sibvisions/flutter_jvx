import '../../ui/screen/so_menu_manager.dart';
import 'i_custom_screen_manager.dart';
import '../../model/api/response/user_data.dart';
import '../../ui/screen/so_component_creator.dart';
import '../../ui/screen/i_screen.dart';

/// Implementation of the [ICustomScreenManager] interface.
class CustomScreenManager extends ICustomScreenManager {
  @override
  IScreen getScreen(String componentId, {String templateName}) {
    return IScreen(SoComponentCreator());
  }

  @override
  void onMenu(SoMenuManager menuManager) {}

  @override
  onUserData(UserData userData) {}
}
