import '../../../service/api/shared/api_object_property.dart';
import '../../component/fl_component_model.dart';
import 'storage_command.dart';

class SaveComponentsCommand extends StorageCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of [FlComponentModel] to save.
  final List<FlComponentModel>? componentsToSave;

  /// List of maps representing the changes done to a component.
  final List<dynamic>? updatedComponent;

  /// Id of Screen to Update
  final String screenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SaveComponentsCommand({
    this.updatedComponent,
    this.componentsToSave,
    required this.screenName,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    String? updateCompIds = updatedComponent?.whereType<Map>().map((e) => e[ApiObjectProperty.id]).join(";");
    return "SaveComponentsCommand{componentsToSave: $componentsToSave, updatedComponent: $updateCompIds, screenName: $screenName, ${super.toString()}}";
  }
}
