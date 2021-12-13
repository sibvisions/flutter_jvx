import '../../api/api_object_property.dart';

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

  /// Name of Screen to Update
  final String screenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SaveComponentsCommand(
      {this.updatedComponent, this.componentsToSave, required this.screenName, required String reason})
      : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString {
    String saveCompIds = " Components to save: [";
    String updateCompIds = " Components to update: [";

    if (componentsToSave != null) {
      for (FlComponentModel element in componentsToSave!) {
        saveCompIds += " " + element.id + ";";
      }

      saveCompIds += "]";
    } else {
      saveCompIds = "";
    }

    if (updatedComponent != null) {
      for (var element in updatedComponent!) {
        if (element is Map) {
          updateCompIds += " " + element[ApiObjectProperty.id] + ";";
        }
      }
      updateCompIds += "]";
    } else {
      updateCompIds = "";
    }

    return "SaveComponentsCommand | " + saveCompIds + updateCompIds + " | Reason : $reason";
  }
}
