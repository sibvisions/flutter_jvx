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

  /// Basically resets the service
  void clear();

  /// Updates [FlComponentModel]
  /// Returns [BaseCommand] to update UI with all effected components.
  List<BaseCommand> saveComponents(
      List<dynamic>? componentsToUpdate, List<FlComponentModel>? newComponents, String screenName);

  /// Deletes Screen Model, and all descendants.
  void deleteScreen({required String screenName});
}
