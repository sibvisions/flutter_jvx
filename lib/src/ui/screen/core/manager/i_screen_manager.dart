
import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/request.dart';

import '../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../models/api/response_objects/user_data_response_object.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../widgets/drawer/menu_drawer_widget.dart';
import '../so_screen.dart';
import 'so_menu_manager.dart';

abstract class IScreenManager {
  /// Method for returning all currently open screens.
  Map<String, SoScreen> get screens;

  /// Method for returning the current [UserData]
  UserDataResponseObject? get userData;

  /// Will be called before [getScreen] is called.
  ///
  /// The method is for registering all kinds of screens
  void init();

  /// Returns an [IScreen] with the given [componentId].
  ///
  /// If null is returned an Error will be thrown.
  /// If you wish to not alter anything you can either return [IScreen(ComponentCreator())]
  /// or you can call [super.getScreen()] which returns the same [IScreen].
  SoScreen? getScreen(String componentId, {String templateName});

  /// If you do not whish to alter anything just return either the [super.onMenu(menuManager)] method
  /// or return the [menuManager] itself.
  SoMenuManager onMenu(SoMenuManager menuManager);

  /// Will be called after a successful login with the current [UserData].
  void onUserData(UserDataResponseObject userData);

  /// Will be called after a successful login
  Future<bool> onLogin(BuildContext context);

  /// Will be called when going online from offline mode
  Future<bool> onSync(BuildContext context);

  /// Is called when a cookie is returned
  String onCookie(String cookie);

  /// Is called when a response is returned
  Future<ApiResponse> onResponse(Request request, List<dynamic> decodedBody);

  /// Used to register a screen for the Screen Manager
  void registerScreen(SoScreen screen);

  /// Method for finding a regsitered Screen
  SoScreen? findScreen(String name);

  /// Method for checking if manager has the screen
  bool hasScreen(String componentId);

  /// Method for removing a registered Screen
  void removeScreen(String name);

  /// Method for updating and/or replacing
  void updateScreen(SoScreen screen);

  SoScreen createScreen(
      {required ApiResponse response,
      Function(String componentId)? onPopPage,
      Function(MenuItem menuItem)? onMenuItemPressed,
      MenuDrawerWidget? drawer});
}
