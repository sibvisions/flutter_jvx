import '../../models/api/response/user_data.dart';
import 'i_screen.dart';
import 'i_screen_manager.dart';
import 'so_menu_manager.dart';
import 'so_screen.dart';

class ScreenManager extends IScreenManager {
  Map<String, SoScreen> _screens = <String, SoScreen>{};

  @override
  IScreen getScreen(String componentId, {String templateName}) {
    SoScreen screen = this.findScreen(componentId);

    if (screen == null) {
      return IScreen();
    }

    return screen;
  }

  @override
  void onMenu(SoMenuManager menuManager) {}

  @override
  onUserData(UserData userData) {}

  @override
  void registerScreen(String name, IScreen screen) {
    _screens.addAll({name: screen});
  }

  @override
  IScreen findScreen(String name) {
    IScreen result;
    _screens.forEach((key, value) => name == key ? result = value : null);
    return result;
  }

  @override
  void removeScreen(String name) {
    _screens.remove(name);
  }

  @override
  void init() {}

  @override
  void updateScreen(SoScreen screen) {
    if (_screens.containsKey(screen.componentId)) {
      _screens[screen.componentId] = screen;
    }
  }
}
