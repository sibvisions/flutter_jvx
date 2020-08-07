import 'package:jvx_flutterclient/jvx_flutterclient.dart';

import '../../ui/screen/so_menu_manager.dart';
import 'i_custom_screen_manager.dart';
import '../../model/api/response/user_data.dart';
import '../../ui/screen/so_component_creator.dart';
import '../../ui/screen/i_screen.dart';

/// Implementation of the [ICustomScreenManager] interface.
class CustomScreenManager extends ICustomScreenManager {
  Map<String, CustomScreen> _screens = <String, CustomScreen>{};

  @override
  IScreen getScreen(String componentId, {String templateName}) {
    return IScreen(SoComponentCreator());
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
  void initScreenManager() {}
}
