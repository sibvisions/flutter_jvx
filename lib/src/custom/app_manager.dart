/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import '../mask/menu/menu.dart';
import '../model/api_interaction.dart';
import '../model/command/base_command.dart';
import '../model/menu/menu_model.dart';
import '../model/request/api_request.dart';
import '../util/debug/debug_detector.dart';
import 'custom_menu_item.dart';
import 'custom_screen.dart';

abstract class AppManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of all registered customs screens.
  final List<CustomScreen> customScreens = [];

  /// The menu item, which is the way to access the registered screens.
  ///
  /// If there is no menu item for a custom screen, we will either:
  /// * Use the original menu item (if this screen replaces an existing screen).
  /// * Create a menu item on best-effort basis using properties of the screen.
  final Map<String, CustomMenuItem> customMenuItems = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppManager();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Registers a custom screen which either replaces an existing screen or adds a new one.
  ///
  /// Although it is recommended to provide your own menu item via [menuItem],
  /// especially when creating a new screen or replacing a screen in offline mode.
  /// there are ways to evade a missing menu item:
  /// * In case of a replacing screen and the screen is only shown online,
  /// the menu item provided by the original screen is being used.
  /// * Otherwise, a menu item is constructed using values from [customScreen].
  ///
  /// A [menuItem] is required when registering an offline-only screen ([CustomScreen.offline]).
  void registerScreen(
    CustomScreen customScreen, {
    CustomMenuItem? menuItem,
  }) {
    assert(
      !customScreen.showOffline || customScreen.showOnline || menuItem != null,
      "Custom offline screens require a menu entry.",
    );
    if (menuItem != null) {
      customMenuItems[customScreen.key] = menuItem;
    }
    customScreens.add(customScreen);
  }

  /// Gets called on menu mode selection. Default implementation returns original [pCurrentMode]
  MenuMode? getMenuMode(MenuMode pCurrentMode) => null;

  /// Gets called on menu model selection. Default implementation returns original [pMenuModel]
  void modifyMenuModel(MenuModel pMenuModel) {}

  /// Can be used to modify the headers for each request
  void modifyHeaders(HttpHeaders headers) {}

  /// Can be used to modify the cookie list for each request
  void modifyCookies(List<Cookie> cookies) {}

  /// Can be used to modify the commands list after the command processor
  void modifyCommands(List<BaseCommand> commands, BaseCommand originalCommand) {}

  /// Can be used to modify the responses list after each request
  void modifyResponses(ApiInteraction responses) {}

  /// Is called when a response is returned, use the [resendRequest] function to resend the original request.
  /// Useful for 2FA or retry.
  Future<HttpClientResponse?> handleResponse(
          ApiRequest request, String responseBody, Future<HttpClientResponse> Function() resendRequest) =>
      Future.value(null);

  /// Is called if a new startup is initiated.
  void onInitStartup() {}

  /// Is called if a new startup is successfully finished.
  void onSuccessfulStartup() {}

  /// Is called when going to the menu.
  void onMenuPage() {}

  /// Is called when going to a workscreen.
  void onScreenPage() {}

  /// Is called when going to the settings.
  void onSettingPage() {}

  /// Is called when going to the login.
  void onLoginPage() {}

// /// Is called if a login is successfully completed.
// void onLoginSuccess() {}

  /// Called when [DebugDetector] gets triggered (Only used when [kDebugMode] is active).
  void onDebugTrigger() {}
}
