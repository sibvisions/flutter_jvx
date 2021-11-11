import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_jvx/src/models/api/component/button/ui_button_model.dart';
import 'package:flutter_jvx/src/models/api/component/panel/ui_panel_model.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_screen_generic.dart';
import 'package:flutter_jvx/src/util/mixin/service/component_store_sevice_mixin.dart';

class ScreenGenericProcessor with ComponentStoreServiceMixin implements IProcessor {

  @override
  void processResponse(json) {
    //Parse to Response Object
    ResponseScreenGeneric screenGeneric = ResponseScreenGeneric.fromJson(json);

    //Create ComponentModels out of changedComponents in separate isolate to not freeze ui.
    Future<List<UiComponentModel>> ft =  compute(_createComponentModels, screenGeneric.changedComponents);

    //Either save or update Component in ComponentStore once all components are parsed
    ft.then((value) => {
      for (UiComponentModel model in value) {
        if (!componentStoreService.saveComponent(model)) {
          componentStoreService.updateComponent(model)
        }
      },
    });
  }


  static List<UiComponentModel> _createComponentModels(List<dynamic> changedComponents) {
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