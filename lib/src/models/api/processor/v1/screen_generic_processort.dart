import 'dart:developer';

import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_screen_generic.dart';

class ScreenGenericProcessor implements IProcessor{

  @override
  void processResponse(json) {
    ResponseScreenGeneric screenGeneric = ResponseScreenGeneric.fromJson(json);

    List<UiComponentModel> models = _createComponentModels(screenGeneric.changedComponents);

    models.forEach((element) {log(element.parent.toString());});
  }


  List<UiComponentModel> _createComponentModels(List<dynamic> changedComponents){

    List<UiComponentModel> models = [];
    for(dynamic changedComponent in changedComponents){
      UiComponentModel model = UiComponentModel.fromJson(changedComponent);
      models.add(model);
    }

    return models;
  }
}