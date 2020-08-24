import '../../jvx_flutterclient.dart';
import '../../model/api/response/user_data.dart';
import '../../ui/screen/i_screen.dart';
import '../../ui/screen/so_component_creator.dart';
import '../../ui/screen/so_menu_manager.dart';
import '../../utils/globals.dart' as globals;
import 'i_custom_screen_manager.dart';

/// Implementation of the [ICustomScreenManager] interface.
class CustomScreenManager extends ICustomScreenManager {
  Map<String, CustomScreen> _screens = <String, CustomScreen>{};

  @override
  IScreen getScreen(String componentId, {String templateName}) {
    globals.currentTempalteName = templateName;

    CustomScreen screen = this.findScreen(componentId);

    if (screen == null) {
      return IScreen(SoComponentCreator());
    }

    screen.setTemplateName(templateName);

    return screen;
  }

  @override
  void onMenu(SoMenuManager menuManager) {}

  @override
  onUserData(UserData userData) {}

  @override
  void registerScreen(String name, CustomScreen screen) {
    _screens.addAll({name: screen});
  }

  @override
  CustomScreen findScreen(String name) {
    CustomScreen result;
    _screens.forEach((key, value) => name == key ? result = value : null);
    return result;
  }

  @override
  void removeScreen(String name) {
    _screens.remove(name);
  }

  @override
  void init() {}
}
