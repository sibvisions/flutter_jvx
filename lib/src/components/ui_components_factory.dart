import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/components/button/ui_button_wrapper.dart';
import 'package:flutter_jvx/src/components/panel/ui_panel_wrapper.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';

abstract class UIComponentFactory {

  static Widget createWidgetFromModel(UiComponentModel model){
    if(model.name == "Button"){
      return UIButtonWrapper(model: model, key: Key(model.id));
    } else if(model.name == "Panel"){
      return UIPanelWrapper(model: model, key: Key(model.id));
    }

    return const Text("IAM A DUMMY");
  }

}