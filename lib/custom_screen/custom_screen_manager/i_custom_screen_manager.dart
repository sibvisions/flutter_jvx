import 'package:jvx_mobile_v3/model/api/response/user_data.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/screen/i_screen.dart';

/// Interface for the [CustomScreenManager] class.
abstract class ICustomScreenManager {
  /// Returns an [IScreen] with the given [componentId].
  /// 
  /// If null is returned an Error will be thrown.
  /// If you wish to not alter anything you can either return [IScreen(ComponentCreator())]
  /// or you can call [super.getScreen()] which returns the same [IScreen].
  IScreen getScreen(String componentId);

  /// Returns a List of [MenuItem]'s with the given [menu].
  /// 
  /// If you do not whish to alter anything just return either the [super.onMenu(menu)] method
  /// or return the [menu] itself.
  List<MenuItem> onMenu(List<MenuItem> menu);

  /// Will be called after a successful login with the current [UserData].
  onUserData(UserData userData);
}