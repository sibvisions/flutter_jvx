import 'package:flutter_client/src/model/component/panel/fl_tab_panel_model.dart';

import '../../../../model/api/api_object_property.dart';
import '../../../../model/api/response/screen_generic_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_components_command.dart';
import '../../../../model/command/ui/route_command.dart';
import '../../../../model/component/button/fl_button_model.dart';
import '../../../../model/component/button/fl_radio_button_model.dart';
import '../../../../model/component/button/fl_toggle_button_model.dart';
import '../../../../model/component/check_box/fl_check_box_model.dart';
import '../../../../model/component/dummy/fl_dummy_model.dart';
import '../../../../model/component/editor/fl_editor_model.dart';
import '../../../../model/component/editor/text_area/fl_text_area_model.dart';
import '../../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/component/label/fl_label_model.dart';
import '../../../../model/component/panel/fl_group_panel_model.dart';
import '../../../../model/component/panel/fl_panel_model.dart';
import '../../../../model/component/panel/fl_split_panel_model.dart';
import '../../../../routing/app_routing_type.dart';
import '../fl_component_classname.dart';
import '../i_processor.dart';

/// Processes [ScreenGenericResponse], will separate (and parse) new and changed components, can also open screens
/// based on the 'update' property of the request.
///
/// Possible return Commands : [SaveComponentsCommand], [RouteCommand]
class ScreenGenericProcessor implements IProcessor<ScreenGenericResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse({required ScreenGenericResponse pResponse}) {
    List<BaseCommand> commands = [];
    ScreenGenericResponse screenGenericResponse = pResponse;

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
      // Containers
      case FlContainerClassname.PANEL:
        model = FlPanelModel();
        break;
      case FlContainerClassname.GROUP_PANEL:
        model = FlGroupPanelModel();
        break;
      case FlContainerClassname.SCROLL_PANEL:
        model = FlPanelModel();
        break;
      case FlContainerClassname.SPLIT_PANEL:
        model = FlSplitPanelModel();
        break;
      case FlContainerClassname.TABSET_PANEL:
        model = FlTabPanelModel();
        break;
      case FlContainerClassname.CUSTOM_CONTAINER:
        continue alsoDefault;

      // Components
      case FlComponentClassname.BUTTON:
        model = FlButtonModel();
        break;
      case FlComponentClassname.TOGGLE_BUTTON:
        model = FlToggleButtonModel();
        break;
      case FlComponentClassname.LABEL:
        model = FlLabelModel();
        break;
      case FlComponentClassname.TEXT_FIELD:
        model = FlTextFieldModel();
        break;
      case FlComponentClassname.TEXT_AREA:
        model = FlTextAreaModel();
        break;
      case FlComponentClassname.ICON:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU:
        continue alsoDefault;
      case FlComponentClassname.MENU_ITEM:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU_BUTTON:
        continue alsoDefault;
      case FlComponentClassname.CHECK_BOX:
        model = FlCheckBoxModel();
        break;
      case FlComponentClassname.PASSWORD_FIELD:
        model = FlTextFieldModel();
        break;
      case FlComponentClassname.TABLE:
        continue alsoDefault;
      case FlComponentClassname.RADIO_BUTTON:
        model = FlRadioButtonModel();
        break;
      case FlComponentClassname.MAP:
        continue alsoDefault;
      case FlComponentClassname.CHART:
        continue alsoDefault;
      case FlComponentClassname.GAUGE:
        continue alsoDefault;

      // Cell editors:
      case FlComponentClassname.EDITOR:
        model = FlEditorModel(json: pJson);
        break;

      alsoDefault:
      default:
        model = FlDummyModel();
    }
    model.applyFromJson(pJson);
    return model;
  }
}
