import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/menu/menu_model.dart';

/// Defines the base construct of a [IStorageService],
/// Storage service is used to store & retrieve all Data of [FlComponentModel] & [MenuModel]
//Author: Michael Schober
abstract class IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Saves the [menuModel] as the current menu, will overwrite any existing menu.
  Future<bool> saveMenu(MenuModel menuModel);

  /// Returns current [menuModel]
  Future<MenuModel> getMenu();

  /// Updates [FlComponentModel]
  /// Returns [BaseCommand] to update UI with all effected components.
  Future<List<BaseCommand>> updateComponents(
      List<dynamic>? componentsToUpdate, List<FlComponentModel>? newComponents, String screenName);

  /// Returns all [FlComponentModel] in the given [screenClassName],
  /// including all children recursively.
  /// First Object of List is always screen (most top) component.
  Future<List<FlComponentModel>> getScreenByScreenClassName(String screenClassName);

  /// Deletes Screen Model, and all descendants.
  Future<void> deleteScreen({required String screenName});
}
