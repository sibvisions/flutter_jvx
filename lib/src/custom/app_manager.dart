import 'package:universal_io/io.dart';

import '../mask/menu/menu.dart';
import '../model/api_interaction.dart';
import '../model/command/base_command.dart';
import '../model/menu/menu_model.dart';
import '../model/request/api_request.dart';
import 'custom_screen.dart';

abstract class AppManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of all registered customs screens
  List<CustomScreen> customScreens = [];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppManager();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Register a screen
  void registerScreen(CustomScreen pCustomScreen) {
    customScreens.add(pCustomScreen);
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
}
