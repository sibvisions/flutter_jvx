import '../../../../model/api/api_object_property.dart';
import '../../../../model/api/response/screen_generic_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_components_command.dart';
import '../../../../model/component/button/fl_button_model.dart';
import '../../../../model/component/dummy/fl_dummy_model.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/component/panel/fl_panel_model.dart';
import '../fl_component_classname.dart';
import '../i_processor.dart';

///
/// Processes [ScreenGenericResponse]
///
class ScreenGenericProcessor implements IProcessor {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(json) {
    List<BaseCommand> commands = [];
    ScreenGenericResponse screenGenericResponse = ScreenGenericResponse.fromJson(json);

    //Check for new full components
    List<FlComponentModel>? componentsToSave = _getNewComponents(screenGenericResponse.changedComponents);

    //Check for changed Components
    List<dynamic>? updatedComponent = _getChangedComponents(screenGenericResponse.changedComponents);

    if (componentsToSave != null || updatedComponent != null) {
      SaveComponentsCommand saveComponentsCommand = SaveComponentsCommand(
          reason: "Api received screen.generic response",
          componentsToSave: componentsToSave,
          updatedComponent: updatedComponent,
          screenName: screenGenericResponse.componentId);
      commands.add(saveComponentsCommand);
    }
    return commands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  List<dynamic>? _getChangedComponents(List<dynamic> pChangedComponents) {
    List<dynamic> changedComponents = [];

    for (dynamic component in pChangedComponents) {
      if (component[ApiObjectProperty.className] == null) {
        changedComponents.add(component);
      }
    }

    if (changedComponents.isNotEmpty) {
      return changedComponents;
    }
  }

  List<FlComponentModel>? _getNewComponents(List<dynamic> changedComponents) {
    List<FlComponentModel> models = [];
    for (dynamic changedComponent in changedComponents) {
      String? className = changedComponent[ApiObjectProperty.className];
      if (className != null) {
        FlComponentModel model = _parseFlComponentModel(changedComponent, className);
        models.add(model);
      }
    }
    if (models.isNotEmpty) {
      return models;
    }
  }

  FlComponentModel _parseFlComponentModel(dynamic json, String className) {
    switch (className) {
      case (FlComponentClassname.panel):
        return FlPanelModel.fromJson(json);
      case (FlComponentClassname.button):
        return FlButtonModel.fromJson(json);
      default:
        return FlDummyModel.fromJson(json);
    }
  }
}
