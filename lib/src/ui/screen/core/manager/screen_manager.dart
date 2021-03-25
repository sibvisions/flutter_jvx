import 'package:flutterclient/src/models/api/response_objects/user_data_response_object.dart';
import 'package:flutterclient/src/ui/screen/core/manager/i_screen_manager.dart';
import 'package:flutterclient/src/ui/screen/core/so_screen.dart';
import 'package:flutterclient/src/ui/screen/core/manager/so_menu_manager.dart';

class ScreenManager implements IScreenManager {
  Map<String, SoScreen> _screens = <String, SoScreen>{};
  UserDataResponseObject? _userData;

  @override
  Map<String, SoScreen> get screens => _screens;

  @override
  UserDataResponseObject? get userData => _userData;

  @override
  SoScreen? getScreen(String componentId, {String? templateName}) {
    SoScreen? screen = this.findScreen(componentId);
    return screen;
  }

  @override
  SoMenuManager onMenu(SoMenuManager menuManager) {
    return menuManager;
  }

  @override
  onUserData(UserDataResponseObject userData) {
    this._userData = userData;
  }

  @override
  void registerScreen(SoScreen screen) {
    _screens.addAll({screen.configuration.componentId: screen});
  }

  @override
  SoScreen? findScreen(String name) {
    SoScreen? result;
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
