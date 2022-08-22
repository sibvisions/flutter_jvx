import 'package:universal_io/io.dart';

import '../src/mask/menu/menu_mode.dart';
import '../src/model/menu/menu_model.dart';
import '../src/model/request/i_api_request.dart';
import 'custom_screen.dart';

export '../src/mask/menu/menu_mode.dart';
export '../src/model/request/i_api_request.dart';
export '../src/model/response/api_response.dart';

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

  /// Can be used to modify the cookie list for each request
  void modifyCookies(List<Cookie> cookies) {}

  /// Is called when a response is returned, use the [resendRequest] function to resend the original request.
  /// Useful for 2FA or retry.
  Future<HttpClientResponse?> handleResponse(
          IApiRequest request, String responseBody, Future<HttpClientResponse> Function() resendRequest) =>
      Future.value(null);
}
