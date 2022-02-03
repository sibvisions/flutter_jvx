import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/button/fl_toggle_button_wrapper.dart';
import 'package:flutter_client/src/components/editor/fl_text_area_wrapper.dart';
import 'package:flutter_client/src/components/editor/fl_text_field_wrapper.dart';
import 'package:flutter_client/src/model/component/button/fl_toggle_button_model.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_area_model.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_field_model.dart';
import 'package:flutter_client/src/service/api/shared/fl_component_classname.dart';
import 'panel/fl_scroll_panel_wrapper.dart';
import 'split_panel/fl_split_panel_wrapper.dart';
import '../model/component/panel/fl_split_panel.dart';

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
      case FlComponentClassname.BUTTON:
        return FlButtonWrapper(model: model as FlButtonModel, key: Key(model.id));
      case FlComponentClassname.TOGGLE_BUTTON:
        return FlToggleButtonWrapper(model: model as FlToggleButtonModel, key: Key(model.id));
      case FlComponentClassname.PANEL:
        return FlPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case FlComponentClassname.LABEL:
        return FlLabelWrapper(model: model as FlLabelModel, key: Key(model.id));
      case FlComponentClassname.TEXT_FIELD:
        return FlTextFieldWrapper(model: model as FlTextFieldModel, key: Key(model.id));
      case FlComponentClassname.TEXT_AREA:
        return FlTextAreaWrapper(model: model as FlTextAreaModel, key: Key(model.id));
      case FlComponentClassname.GROUP_PANEL:
        return FlPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case FlComponentClassname.SCROLL_PANEL:
        return FlScrollPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case FlComponentClassname.SPLIT_PANEL:
        return FlSplitPanelWrapper(model: model as FlSplitPanelModel, key: Key(model.id));
      default:
        return DummyWrapper(model: model as FlDummyModel, key: Key(model.id));
    }
  }
}
