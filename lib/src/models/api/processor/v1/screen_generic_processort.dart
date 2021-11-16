import 'package:flutter_jvx/src/models/api/action/component_action.dart';
import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/models/api/component/button/ui_button_model.dart';
import 'package:flutter_jvx/src/models/api/component/panel/ui_panel_model.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_screen_generic.dart';

class ScreenGenericProcessor implements IProcessor {

  @override
  List<ProcessorAction> processResponse(json) {
    List<ProcessorAction>  actions = [];
    ResponseScreenGeneric screenGeneric = ResponseScreenGeneric.fromJson(json);


    List<UiComponentModel> componentModels = _createComponentModels(screenGeneric.changedComponents);

    for(UiComponentModel componentModel in componentModels){
      ComponentAction componentAction = ComponentAction(componentModel: componentModel);
      actions.add(componentAction);
    }
    return actions;
  }


  List<UiComponentModel> _createComponentModels(List<dynamic> changedComponents) {
    List<UiComponentModel> models = [];
    for (dynamic changedComponent in changedComponents) {
      UiComponentModel model = UiComponentModel.fromJson(changedComponent);
      if(model.className == "Panel") {
        model = UiPanelModel.fromJson(changedComponent);
      } else if(model.className == "Button") {
        model = UIButtonModel.fromJson(changedComponent);
      }
      models.add(model);
    }
    return models;
  }
}