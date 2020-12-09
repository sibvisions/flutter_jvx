import '../../models/api/response/user_data.dart';
import 'i_screen.dart';
import 'i_screen_manager.dart';
import 'so_menu_manager.dart';

class ScreenManager extends IScreenManager {
  Map<String, IScreen> _screens = <String, IScreen>{};

  @override
  Map<String, IScreen> get screens => _screens;

  @override
  IScreen getScreen(String componentId, {String templateName}) {
    IScreen screen = this.findScreen(componentId);

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
  void registerScreen(IScreen screen) {
    _screens.addAll({screen.componentId: screen});
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
  void updateScreen(IScreen screen) {
    if (_screens.containsKey(screen.componentId)) {
      _screens[screen.componentId] = screen;
    }
  }
}
