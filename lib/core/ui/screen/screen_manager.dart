import 'package:jvx_flutterclient/core/ui/screen/so_screen.dart';

import '../../models/api/response/user_data.dart';
import 'i_screen_manager.dart';
import 'so_menu_manager.dart';

class ScreenManager extends IScreenManager {
  Map<String, SoScreen> _screens = <String, SoScreen>{};
  UserData _userData;

  @override
  Map<String, SoScreen> get screens => _screens;

  @override
  UserData get userData => _userData;

  @override
  SoScreen getScreen(String componentId, {String templateName}) {
    SoScreen screen = this.findScreen(componentId);
    return screen;
  }

  @override
  void onMenu(SoMenuManager menuManager) {}

  @override
  onUserData(UserData userData) {
    this._userData = userData;
  }

  @override
  void registerScreen(SoScreen screen) {
    _screens.addAll({screen.configuration.componentId: screen});
  }

  @override
  SoScreen findScreen(String name) {
    SoScreen result;
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
    if (_screens.containsKey(screen.configuration.componentId)) {
      _screens[screen.configuration.componentId] = screen;
    }
  }
}
