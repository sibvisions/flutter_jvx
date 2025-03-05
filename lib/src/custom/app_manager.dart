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

import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:universal_io/io.dart';

import '../../flutter_jvx.dart';
import '../components/list/fl_list_entry.dart';

abstract class AppManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all registered customs screens.
  final LinkedHashMap<String, CustomScreen> customScreens = LinkedHashMap();

  /// Custom components that will replace original components.
  final Map<String, CustomComponent> replaceComponents = {};

  /// The menu item, which is the way to access the registered screens.
  ///
  /// If there is no menu item for a custom screen, we will either:
  /// * Use the original menu item (if this screen replaces an existing screen).
  /// * Create a menu item on best-effort basis using properties of the screen.
  final Map<String, CustomMenuItem> customMenuItems = {};

  /// Map of all custom list entry builder.
  final Map<String, ListEntryBuilder> customListEntryBuilder = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppManager();

  /// Called after [FlutterUI] finished initializing.
  ///
  /// Can be used to initialize the manager using async methods.
  Future<void> init() async {}

  /// Called when [FlutterUI] is being disposed.
  ///
  /// Can be used to dispose this manager.
  void dispose() {}

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
  /// A [menuItem] is required when registering an offline screen ([CustomScreen.offline]).
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
    customScreens[customScreen.key] = customScreen;
  }

  /// Defines a custom component which is a replacement for an existing component
  void replaceComponent(CustomComponent customComponent) {
    replaceComponents[customComponent.componentName] = customComponent;
  }

  /// Registers a custom list entry builder for the given [componentName]
  void registerListEntryBuilder(String componentName, ListEntryBuilder builder) {
    customListEntryBuilder[componentName] = builder;
  }

  /// Gets called on menu mode selection. Default implementation returns original [pCurrentMode]
  MenuMode onMenuMode(MenuMode pCurrentMode) => pCurrentMode;

  /// Gets called on menu model selection.
  void modifyMenuModel(MenuModel pMenuModel) {}

  /// This lets you modify the list of actions shown in the app bar.
  List<Widget> getAdditionalActions() => [];

  /// Can be used to modify the headers for each request
  void modifyHeaders(Map<String, dynamic> headers) {}

  /// Can be used to modify the cookie list for each request
  void modifyCookies(List<Cookie> cookies) {}

  /// Can be used to modify the application parameters before they get updated via [IUiService.updateApplicationParameters]
  void modifyApplicationParameters(ApplicationParameters pApplicationParameters) {}

  /// Can be used to modify a command which is to be executed. Default implementation returns original [pSentCommand]
  /// This method can be used to modify command properties, return a different command or even return null to cancel the command.
  ///
  /// Be warned! This method gets executed on every possible command.
  /// Significant performance issues can arise in the whole application the more this function takes to compute.
  /// This method can be called multiple times within a second.
  BaseCommand? interceptCommand(BaseCommand pSentCommand) => pSentCommand;

  /// Can be used to modify the commands which follow on a recently executed command.
  /// This method can be used to modify command properties, return different commands or remove commands to cancel them.
  ///
  /// Be warned! This method gets executed on every possible command.
  /// Significant performance issues can arise in the whole application the more this function takes to compute.
  /// This method can be called multiple times within a second.
  void modifyFollowUpCommands(BaseCommand pParentCommand, List<BaseCommand> pFollowUpCommands) {}

  /// Can be used to modify the responses list after each request
  void modifyResponses(ApiInteraction responses) {}

  /// Is called when a response is returned, use the [resendRequest] function to resend the original request.
  /// Useful for 2FA or retry.
  ///
  /// Currently [Response.data] is always going to be a [Uint8List] to provide maximum flexibility.
  Future<Response> handleResponse(
    ApiRequest request,
    Response originalResponse,
    Future<Response> Function() resendRequest,
  ) =>
      Future.value(originalResponse);

  /// Is called if a new startup is initiated.
  void onInitStartup() {}

  /// Is called if a new startup is successfully finished.
  void onSuccessfulStartup() {}

  /// Is called when going to the menu.
  ///
  /// This happens either directly after the startup (in case of an auto-login) or after the login.
  void onMenuPage() {}

  /// Is called when going to a workscreen.
  void onScreenPage(String pScreenName) {}

  /// Is called when going to the settings.
  void onSettingPage() {}

  /// Is called when going to the login.
  void onLoginPage() {}
}
