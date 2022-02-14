import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'button/fl_toggle_button_wrapper.dart';
import 'editor/fl_editor_wrapper.dart';
import '../model/component/button/fl_toggle_button_model.dart';
import '../model/component/editor/fl_editor_model.dart';
import '../model/component/editor/fl_text_area_model.dart';
import '../model/component/editor/fl_text_field_model.dart';
import '../service/api/shared/fl_component_classname.dart';
import 'editor/text_area/fl_text_area_wrapper.dart';
import 'editor/text_field/fl_text_field_wrapper.dart';
import 'panel/fl_scroll_panel_wrapper.dart';
import 'split_panel/fl_split_panel_wrapper.dart';
import '../model/component/panel/fl_split_panel.dart';

import '../model/component/button/fl_button_model.dart';
import '../model/component/dummy/fl_dummy_model.dart';
import '../model/component/fl_component_model.dart';
import '../model/component/label/fl_label_model.dart';
import '../model/component/panel/fl_panel_model.dart';
import 'button/fl_button_wrapper.dart';
import 'dummy/fl_dummy_wrapper.dart';
import 'label/fl_label_wrapper.dart';
import 'panel/fl_panel_wrapper.dart';

abstract class ComponentsFactory {
  static Widget buildWidget(FlComponentModel model) {
    switch (model.className) {
      // Containers
      case FlContainerClassname.PANEL:
        return FlPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case FlContainerClassname.GROUP_PANEL:
        return FlPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case FlContainerClassname.SCROLL_PANEL:
        return FlScrollPanelWrapper(model: model as FlPanelModel, key: Key(model.id));
      case FlContainerClassname.SPLIT_PANEL:
        return FlSplitPanelWrapper(model: model as FlSplitPanelModel, key: Key(model.id));
      case FlContainerClassname.TABSET_PANEL:
        continue alsoDefault;
      case FlContainerClassname.CUSTOM_CONTAINER:
        continue alsoDefault;

      // Components
      case FlComponentClassname.BUTTON:
        return FlButtonWrapper(model: model as FlButtonModel, key: Key(model.id));
      case FlComponentClassname.TOGGLE_BUTTON:
        return FlToggleButtonWrapper(model: model as FlToggleButtonModel, key: Key(model.id));
      case FlComponentClassname.LABEL:
        return FlLabelWrapper(model: model as FlLabelModel, key: Key(model.id));
      case FlComponentClassname.TEXT_FIELD:
        return FlTextFieldWrapper(model: model as FlTextFieldModel, key: Key(model.id));
      case FlComponentClassname.TEXT_AREA:
        return FlTextAreaWrapper(model: model as FlTextAreaModel, key: Key(model.id));
      case FlComponentClassname.ICON:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU:
        continue alsoDefault;
      case FlComponentClassname.MENU_ITEM:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU_BUTTON:
        continue alsoDefault;
      case FlComponentClassname.CHECK_BOX:
        continue alsoDefault;
      case FlComponentClassname.PASSWORD_FIELD:
        continue alsoDefault;
      case FlComponentClassname.TABLE:
        continue alsoDefault;
      case FlComponentClassname.RADIO_BUTTON:
        continue alsoDefault;
      case FlComponentClassname.MAP:
        continue alsoDefault;
      case FlComponentClassname.CHART:
        continue alsoDefault;
      case FlComponentClassname.GAUGE:
        continue alsoDefault;

      // Cell editors:
      case FlComponentClassname.EDITOR:
        return FlEditorWrapper(model: model as FlEditorModel, key: Key(model.id));

      alsoDefault:
      default:
        return FlDummyWrapper(model: model as FlDummyModel, key: Key(model.id));
    }
  }
}
