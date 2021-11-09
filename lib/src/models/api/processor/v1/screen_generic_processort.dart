import 'dart:developer';

import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_screen_generic.dart';
import 'package:flutter_jvx/src/util/mixin/service/component_store_sevice_mixin.dart';

class ScreenGenericProcessor with ComponentStoreServiceMixin implements IProcessor{

  @override
  void processResponse(json) {
    //Parse to Response Object
    ResponseScreenGeneric screenGeneric = ResponseScreenGeneric.fromJson(json);

    //Create ComponentModels out of changedComponents
    List<UiComponentModel> models = _createComponentModels(screenGeneric.changedComponents);

    //Either save or update Component in ComponentStore
    for(UiComponentModel model in models){
      if(!componentStoreService.saveComponent(model)){
        componentStoreService.updateComponent(model);
      }
    }
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