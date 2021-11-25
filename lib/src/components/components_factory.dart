import 'dart:developer';

import 'button/fl_button_wrapper.dart';
import 'panel/fl_panel_wrapper.dart';
import '../model/component/button/fl_button_model.dart';
import '../model/component/fl_component_model.dart';
import '../model/component/panel/fl_panel_model.dart';
import 'package:flutter/cupertino.dart';

abstract class ComponentsFactory {

  static Widget buildWidget(FlComponentModel model){
    switch(model.className){
      case("Button") :
        return FlButtonWrapper(model: model as FlButtonModel);
      case("Panel") :
        return FlPanelWrapper(model: model as FlPanelModel);
      default :
        return const Text("abc");
    }
  }

}