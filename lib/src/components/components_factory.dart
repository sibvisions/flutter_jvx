import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/split_panel/fl_split_panel_wrapper.dart';
import 'package:flutter_client/src/model/component/panel/fl_split_panel.dart';

import '../model/component/button/fl_button_model.dart';
import '../model/component/dummy/fl_dummy_model.dart';
import '../model/component/fl_component_model.dart';
import '../model/component/label/fl_label_model.dart';
import '../model/component/panel/fl_panel_model.dart';
import 'button/fl_button_wrapper.dart';
import 'dummy/dummy_wrapper.dart';
import 'label/fl_label_wrapper.dart';
import 'panel/fl_panel_wrapper.dart';

abstract class ComponentsFactory {
  static Widget buildWidget(FlComponentModel model) {
    switch (model.className) {
      case ("Button"):
        return FlButtonWrapper(model: model as FlButtonModel, key: Key(model.id));
      case ("Panel"):
        return FlPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case ("Label"):
        return FlLabelWrapper(model: model as FlLabelModel, key: Key(model.id));
      case ("GroupPanel"):
        return FlPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case ("ScrollPanel"):
        return FlPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case ("SplitPanel"):
        return FlSplitPanelWrapper(model: model as FlSplitPanelModel, key: Key(model.id));
      default:
        return DummyWrapper(model: model as FlDummyModel, key: Key(model.id));
    }
  }
}
