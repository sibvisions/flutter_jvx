import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/request.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../../models/api/response_objects/user_data_response_object.dart';
import '../../../../models/state/app_state.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../widgets/drawer/menu_drawer_widget.dart';
import '../configuration/so_screen_configuration.dart';
import '../so_component_creator.dart';
import '../so_screen.dart';
import 'i_screen_manager.dart';
import 'so_menu_manager.dart';

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
    _screens.addAll({screen.configuration.screenComponentId: screen});
  }

  @override
  SoScreen? findScreen(String name) {
    SoScreen? result;

    try {
      result = screens.values
          .toList()
          .firstWhere((screen) => screen.configuration.componentId == name);
    } catch (e) {}

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

  @override
  SoScreen createScreen({
    required ApiResponse response,
    Function(String componentId)? onPopPage,
    Function(MenuItem menuItem)? onMenuItemPressed,
    MenuDrawerWidget? drawer,
  }) {
    ScreenGenericResponseObject? screenGeneric =
        response.getObjectByType<ScreenGenericResponseObject>();

    SoScreen screen = SoScreen(
      creator: SoComponentCreator(),
      configuration: SoScreenConfiguration(
          screenComponentId: sl<AppState>().currentMenuComponentId ?? '',
          drawer: drawer ?? SizedBox(),
          componentId: screenGeneric!.componentId!,
          response: response,
          screenTitle: screenGeneric.screenTitle!,
          withServer: true,
          offlineScreen: false,
          onPopPage: onPopPage,
          onMenuItemPressed: onMenuItemPressed),
    );

    return screen;
  }

  @override
  bool hasScreen(String componentId) {
    SoScreen? screen;

    try {
      screen = screens.values.firstWhere(
          (element) => element.configuration.componentId == componentId);
    } catch (e) {
      return false;
    }

    if (screen != null) {
      return true;
    }

    return false;
  }

  @override
  Future<bool> onLogin(BuildContext context) async {
    return true;
  }

  @override
  Future<bool> onSync(BuildContext context) async {
    return true;
  }

  @override
  String onCookie(String cookie) {
    return cookie;
  }

  @override
  Future<bool> onResponse(Request request, String responseBody) async {
    return true;
  }
}
