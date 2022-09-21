import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/menu/menu_model.dart';
import '../service.dart';

/// Defines the base construct of a [IStorageService],
/// Storage service is used to store & retrieve all Data of [FlComponentModel] & [MenuModel]
abstract class IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory IStorageService() => services<IStorageService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Updates [FlComponentModel]
  /// Returns [BaseCommand] to update UI with all effected components.
  List<BaseCommand> saveComponents(
      List<dynamic>? componentsToUpdate, List<FlComponentModel>? newComponents, String screenName);

  /// Returns all [FlComponentModel] in the given [screenClassName],
  /// including all children recursively.
  /// First Object of List is always screen (most top) component.
  List<FlComponentModel> getScreenByScreenClassName(String screenClassName);

  /// Deletes Screen Model, and all descendants.
  void deleteScreen({required String screenName});
}
