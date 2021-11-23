import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';

/// Defines the base construct of a [IStorageService],
/// Storage service is used to store & retrieve all Data of [FlComponentModel] & [MenuModel]
//Author: Michael Schober
abstract class IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Saves the [menuModel] as the current menu, will overwrite any existing menu.
  void saveMenu(MenuModel menuModel);

  /// Returns current [menuModel], if none is set will return null.
  MenuModel? getMenu();

  /// Saves all [FlComponentModel], if already present will update existing model.
  void saveComponent(List<FlComponentModel> components);

  /// Returns all [FlComponentModel] in the given [screenClassName],
  /// including all children recursively.
  /// First Object of List is always screen (most top) component.
  /// If no matching [FlComponentModel] is found, it will return null.
  List<FlComponentModel>? getScreenByScreenClassName(String screenClassName);

}