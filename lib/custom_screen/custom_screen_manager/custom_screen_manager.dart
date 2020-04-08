import '../../ui/screen/menu_manager.dart';
import 'i_custom_screen_manager.dart';
import '../../model/api/response/user_data.dart';
import '../../ui/screen/component_creator.dart';
import '../../ui/screen/i_screen.dart';

/// Implementation of the [ICustomScreenManager] interface.
class CustomScreenManager extends ICustomScreenManager {
  @override
  IScreen getScreen(String componentId) {
    return IScreen(ComponentCreator());
  }

  @override
  void onMenu(JVxMenuManager menuManager) {
  }

  @override
  onUserData(UserData userData) {}
}