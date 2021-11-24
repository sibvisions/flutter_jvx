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
    List<FlComponentModel> parsedComponents = _parseChangedObjects(screenGenericResponse.changedComponents);
    SaveComponentsCommand saveComponentsCommand = SaveComponentsCommand(
        componentsToSave: parsedComponents,
        reason: "Components parsed from a Screen.Generic Request"
    );
    commands.add(saveComponentsCommand);


    return commands;
  }


  List<FlComponentModel> _parseChangedObjects(List<dynamic> changedComponents) {
    List<FlComponentModel> models = [];
     for(dynamic changedComponent in changedComponents){
       String? className = changedComponent[ApiObjectProperty.className];
       if(className != null){
         FlComponentModel model = _parseFlComponentModel(changedComponent, className);
         models.add(model);
       }
     }

    return models;
  }


  FlComponentModel _parseFlComponentModel(dynamic json, String className){
    switch(className){
      case(FlComponentClassname.panel) :
        return FlPanelModel.fromJson(json);
      case(FlComponentClassname.button) :
        return FlButtonModel.fromJson(json);
      default :
        return FlComponentModel.fromJson(json);
    }
  }
}