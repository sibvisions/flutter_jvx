import 'dart:html';

import 'package:flutter_client/src/model/api/api_object_property.dart';

import 'storage_command.dart';
import '../../component/fl_component_model.dart';

class SaveComponentsCommand extends StorageCommand {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of [FlComponentModel] to save.
  final List<FlComponentModel>? componentsToSave;

  /// List of maps representing the changes done to a component.
  final List<dynamic>? updatedComponent;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SaveComponentsCommand({
    this.updatedComponent,
    this.componentsToSave,
    required String reason
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString {
    String saveCompIds = " Components to save: [";
    String updateCompIds = " Components to update: [";

    if (componentsToSave != null)
    {
      for (FlComponentModel element in componentsToSave!)
      {
        saveCompIds += " " + element.id + ";";
      }

      saveCompIds += "]";
    }
    else
    {
      saveCompIds = "";
    }

    if (updatedComponent != null)
    {
      for (var element in updatedComponent!)
      {
        if (element is Map)
        {
          updateCompIds += " " + element[ApiObjectProperty.id] + ";";
        }
      }
      updateCompIds += "]";
    }
    else
    {
      updateCompIds = "";
    }

    return "SaveComponentsCommand | " + saveCompIds + updateCompIds + " | Reason : $reason";
  }

}