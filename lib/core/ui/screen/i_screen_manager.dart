import 'package:jvx_flutterclient/core/ui/screen/so_screen.dart';

import '../../models/api/response/user_data.dart';
import 'so_menu_manager.dart';

/// Interface for the [ScreenManager] class.
abstract class IScreenManager {

  /// Method for returning all currently open screens.
  Map<String, SoScreen> get screens;

  /// Will be called before [getScreen] is called.
  ///
  /// The method is for registering all kinds of screens
  void init();

  /// Returns an [IScreen] with the given [componentId].
  ///
  /// If null is returned an Error will be thrown.
  /// If you wish to not alter anything you can either return [IScreen(ComponentCreator())]
  /// or you can call [super.getScreen()] which returns the same [IScreen].
  SoScreen getScreen(String componentId, {String templateName});

  /// If you do not whish to alter anything just return either the [super.onMenu(menuManager)] method
  /// or return the [menuManager] itself.
  void onMenu(SoMenuManager menuManager);

  /// Will be called after a successful login with the current [UserData].
  void onUserData(UserData userData);

  /// Used to register a screen for the Screen Manager
  void registerScreen(SoScreen screen);

  /// Method for finding a regsitered Screen
  SoScreen findScreen(String name);

  /// Method for removing a registered Screen
  void removeScreen(String name);

  /// Method for updating and/or replacing
  void updateScreen(SoScreen screen);
}
