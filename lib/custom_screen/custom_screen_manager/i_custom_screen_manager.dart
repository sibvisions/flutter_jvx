import '../../ui/screen/so_menu_manager.dart';
import '../../model/api/response/user_data.dart';
import '../../ui/screen/i_screen.dart';

/// Interface for the [CustomScreenManager] class.
abstract class ICustomScreenManager {
  /// Returns an [IScreen] with the given [componentId].
  ///
  /// If null is returned an Error will be thrown.
  /// If you wish to not alter anything you can either return [IScreen(ComponentCreator())]
  /// or you can call [super.getScreen()] which returns the same [IScreen].
  IScreen getScreen(String componentId, {String templateName});

  /// If you do not whish to alter anything just return either the [super.onMenu(menuManager)] method
  /// or return the [menuManager] itself.
  void onMenu(SoMenuManager menuManager);

  /// Will be called after a successful login with the current [UserData].
  onUserData(UserData userData);
}
