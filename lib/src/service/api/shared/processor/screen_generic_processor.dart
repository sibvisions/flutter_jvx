import '../../../../model/component/panel/fl_split_panel.dart';

import '../../../../model/command/ui/route_command.dart';
import '../../../../model/component/label/fl_label_model.dart';
import '../../../../routing/app_routing_type.dart';

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

/// Processes [ScreenGenericResponse], will separate (and parse) new and changed components, can also open screens
/// based on the 'update' property of the request.
///
/// Possible return Commands : [SaveComponentsCommand], [RouteCommand]
class ScreenGenericProcessor implements IProcessor {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(json) {
    List<BaseCommand> commands = [];
    ScreenGenericResponse screenGenericResponse = ScreenGenericResponse.fromJson(json);

    // Handle New & Changed Components
    // Get new full components
    List<FlComponentModel>? componentsToSave = _getNewComponents(screenGenericResponse.changedComponents);

    // Get changed Components
    List<dynamic>? updatedComponent = _getChangedComponents(screenGenericResponse.changedComponents);

    if (componentsToSave != null || updatedComponent != null) {
      SaveComponentsCommand saveComponentsCommand = SaveComponentsCommand(
          reason: "Api received screen.generic response",
          componentsToSave: componentsToSave,
          updatedComponent: updatedComponent,
          screenName: screenGenericResponse.componentId);
      commands.add(saveComponentsCommand);
    }

    // Handle Screen Opening
    if (!screenGenericResponse.update) {
      dynamic json = screenGenericResponse.changedComponents
          .firstWhere((element) => element[ApiObjectProperty.screenClassName] != null);
      String screenClassName = json[ApiObjectProperty.screenClassName];

      RouteCommand routeCommand = RouteCommand(
          routeType: AppRoutingType.workScreen,
          reason: "Screen generic update was set to false.",
          screenName: screenClassName);
      commands.add(routeCommand);
    }
    return commands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns List of all changed components json, or null if none are found.
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

  /// Returns List of new [FlComponentModel] models parsed from json, only components with a [ApiObjectProperty.className] are considered new, if none are found will return null.
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

  /// Parses json component into its appropriate [FlComponentModel], which is termite by its [ApiObjectProperty.className].
  FlComponentModel _parseFlComponentModel(dynamic pJson, String className) {
    FlComponentModel model;
    switch (className) {
      case (FlComponentClassname.panel):
        model = FlPanelModel();
        break;
      case (FlComponentClassname.button):
        model = FlButtonModel();
        break;
      case (FlComponentClassname.label):
        model = FlLabelModel();
        break;
      case (FlComponentClassname.groupPanel):
        model = FlPanelModel();
        break;
      case (FlComponentClassname.scrollPanel):
        model = FlPanelModel();
        break;
      case (FlComponentClassname.splitPanel):
        model = FlSplitPanelModel();
        break;
      default:
        model = FlDummyModel();
        break;
    }
    model.applyFromJson(pJson);
    return model;
  }
}
