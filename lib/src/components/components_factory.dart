import 'dart:developer';

import 'package:flutter_client/src/components/button/fl_button_wrapper.dart';
import 'package:flutter_client/src/components/panel/fl_panel_wrapper.dart';
import 'package:flutter_client/src/model/component/button/fl_button_model.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';
import 'package:flutter/cupertino.dart';

abstract class ComponentsFactory {

  static Widget buildWidget(FlComponentModel model){
    log(model.className);
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