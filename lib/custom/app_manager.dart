import '../src/model/menu/menu_model.dart';
import '../src/service/config/i_config_service.dart';
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

  /// Gets called on menu mode selection. Default implementation returns original [pMenuMode]
  MenuMode onMenuMode(MenuMode pMenuMode) => pMenuMode;

  /// Gets called on menu model selection. Default implementation returns original [pMenuModel]
  MenuModel onMenuModel(MenuModel pMenuModel) => pMenuModel;

  /// Register a screen too
  void registerScreen(CustomScreen pCustomScreen) {
    customScreens.add(pCustomScreen);
  }
}
