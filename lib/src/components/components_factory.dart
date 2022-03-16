import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/panel/tabset/fl_tab_panel_wrapper.dart';
import 'package:flutter_client/src/model/component/panel/fl_tab_panel_model.dart';

import '../model/component/button/fl_button_model.dart';
import '../model/component/button/fl_radio_button_model.dart';
import '../model/component/button/fl_toggle_button_model.dart';
import '../model/component/check_box/fl_check_box_model.dart';
import '../model/component/dummy/fl_dummy_model.dart';
import '../model/component/editor/fl_editor_model.dart';
import '../model/component/editor/text_area/fl_text_area_model.dart';
import '../model/component/editor/text_field/fl_text_field_model.dart';
import '../model/component/fl_component_model.dart';
import '../model/component/label/fl_label_model.dart';
import '../model/component/panel/fl_group_panel_model.dart';
import '../model/component/panel/fl_panel_model.dart';
import '../model/component/panel/fl_split_panel_model.dart';
import '../service/api/shared/fl_component_classname.dart';
import 'button/fl_button_wrapper.dart';
import 'button/radio/fl_radio_button_wrapper.dart';
import 'button/toggle/fl_toggle_button_wrapper.dart';
import 'check_box/fl_check_box_wrapper.dart';
import 'dummy/fl_dummy_wrapper.dart';
import 'editor/fl_editor_wrapper.dart';
import 'editor/password_field/fl_password_wrapper.dart';
import 'editor/text_area/fl_text_area_wrapper.dart';
import 'editor/text_field/fl_text_field_wrapper.dart';
import 'label/fl_label_wrapper.dart';
import 'panel/fl_panel_wrapper.dart';
import 'panel/group/fl_group_panel_wrapper.dart';
import 'panel/scroll/fl_scroll_panel_wrapper.dart';
import 'panel/split/fl_split_panel_wrapper.dart';

//GlobalKey()
abstract class ComponentsFactory {
  static Widget buildWidget(FlComponentModel model) {
    switch (model.className) {
      // Containers
      case FlContainerClassname.PANEL:
        return FlPanelWrapper(model: model as FlPanelModel, key: GlobalKey());
      case FlContainerClassname.GROUP_PANEL:
        return FlGroupPanelWrapper(model: model as FlGroupPanelModel, key: GlobalKey());
      case FlContainerClassname.SCROLL_PANEL:
        return FlScrollPanelWrapper(model: model as FlPanelModel, key: GlobalKey());
      case FlContainerClassname.SPLIT_PANEL:
        return FlSplitPanelWrapper(model: model as FlSplitPanelModel, key: GlobalKey());
      case FlContainerClassname.TABSET_PANEL:
        return FlTabPanelWrapper(model: model as FlTabPanelModel, key: GlobalKey());
      case FlContainerClassname.CUSTOM_CONTAINER:
        continue alsoDefault;

      // Components
      case FlComponentClassname.BUTTON:
        return FlButtonWrapper(model: model as FlButtonModel, key: GlobalKey());
      case FlComponentClassname.TOGGLE_BUTTON:
        return FlToggleButtonWrapper(model: model as FlToggleButtonModel, key: GlobalKey());
      case FlComponentClassname.LABEL:
        return FlLabelWrapper(model: model as FlLabelModel, key: GlobalKey());
      case FlComponentClassname.TEXT_FIELD:
        return FlTextFieldWrapper(model: model as FlTextFieldModel, key: GlobalKey());
      case FlComponentClassname.TEXT_AREA:
        return FlTextAreaWrapper(model: model as FlTextAreaModel, key: GlobalKey());
      case FlComponentClassname.ICON:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU:
        continue alsoDefault;
      case FlComponentClassname.MENU_ITEM:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU_BUTTON:
        continue alsoDefault;
      case FlComponentClassname.CHECK_BOX:
        return FlCheckBoxWrapper(model: model as FlCheckBoxModel, key: GlobalKey());
      case FlComponentClassname.PASSWORD_FIELD:
        return FlPasswordFieldWrapper(model: model as FlTextFieldModel, key: GlobalKey());
      case FlComponentClassname.TABLE:
        continue alsoDefault;
      case FlComponentClassname.RADIO_BUTTON:
        return FlRadioButtonWrapper(model: model as FlRadioButtonModel, key: GlobalKey());
      case FlComponentClassname.MAP:
        continue alsoDefault;
      case FlComponentClassname.CHART:
        continue alsoDefault;
      case FlComponentClassname.GAUGE:
        continue alsoDefault;

      // Cell editors:
      case FlComponentClassname.EDITOR:
        return FlEditorWrapper(model: model as FlEditorModel, key: GlobalKey());

      alsoDefault:
      default:
        return FlDummyWrapper(model: model as FlDummyModel, key: GlobalKey());
    }
  }
}
