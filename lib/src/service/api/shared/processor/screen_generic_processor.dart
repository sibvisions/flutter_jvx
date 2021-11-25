import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/storage/update_component_command.dart';
import 'package:flutter_client/src/model/component/dummy/fl_dummy_model.dart';

import '../../../../model/api/api_object_property.dart';
import '../../../../model/api/response/screen_generic_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_components_command.dart';
import '../../../../model/component/button/fl_button_model.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/component/panel/fl_panel_model.dart';
import '../fl_component_classname.dart';
import '../i_processor.dart';

///
/// Processes [ScreenGenericResponse]
///
class ScreenGenericProcessor implements IProcessor {

  @override
  List<BaseCommand> processResponse(json) {
    List<BaseCommand> commands = [];
    ScreenGenericResponse screenGenericResponse = ScreenGenericResponse.fromJson(json);

    //Check for new full components
    List<FlComponentModel>? parsedNewComponent = _getNewComponents(screenGenericResponse.changedComponents);
    if(parsedNewComponent != null){
      SaveComponentsCommand saveComponentsCommand = SaveComponentsCommand(
          componentsToSave: parsedNewComponent,
          reason: "Components parsed from a Screen.Generic Request"
      );
      commands.add(saveComponentsCommand);
    }

    //Check for changed Components
    List<dynamic>? unparsedChangedComponent = _getChangedComponents(screenGenericResponse.changedComponents);
    if(unparsedChangedComponent != null){
      UpdateComponentCommand updateComponentCommand = UpdateComponentCommand(
          changedComponents: unparsedChangedComponent,
          reason: "Components updated in screen.generic response"
      );
      commands.add(updateComponentCommand);
    }



    return commands;
  }


  List<dynamic>? _getChangedComponents(List<dynamic> pChangedComponents) {
    List<dynamic> changedComponents = [];

    for (dynamic component in pChangedComponents) {
      if(component[ApiObjectProperty.className] == null){
        changedComponents.add(component);
      }
    }

    if(changedComponents.isNotEmpty){
      return changedComponents;
    }
  }


  List<FlComponentModel>? _getNewComponents(List<dynamic> changedComponents) {
    List<FlComponentModel> models = [];
     for(dynamic changedComponent in changedComponents){
       String? className = changedComponent[ApiObjectProperty.className];
       if(className != null){
         FlComponentModel model = _parseFlComponentModel(changedComponent, className);
         models.add(model);
       }
     }
     if(models.isNotEmpty){
       return models;
     }
  }


  FlComponentModel _parseFlComponentModel(dynamic json, String className){
    switch(className){
      case(FlComponentClassname.panel) :
        return FlPanelModel.fromJson(json);
      case(FlComponentClassname.button) :
        return FlButtonModel.fromJson(json);
      default :
        return FlDummyModel.fromJson(json);
    }
  }
}