import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/icon/fl_icon_wrapper.dart';
import 'package:flutter_client/src/components/map/fl_map_wrapper.dart';
import 'package:flutter_client/src/components/panel/tabset/fl_tab_panel_wrapper.dart';
import 'package:flutter_client/src/components/table/fl_table_wrapper.dart';

import '../model/component/fl_component_model.dart';
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
        return FlPanelWrapper(id: model.id, key: GlobalKey());
      case FlContainerClassname.GROUP_PANEL:
        return FlGroupPanelWrapper(id: model.id, key: GlobalKey());
      case FlContainerClassname.SCROLL_PANEL:
        return FlScrollPanelWrapper(id: model.id, key: GlobalKey());
      case FlContainerClassname.SPLIT_PANEL:
        return FlSplitPanelWrapper(id: model.id, key: GlobalKey());
      case FlContainerClassname.TABSET_PANEL:
        return FlTabPanelWrapper(id: model.id, key: GlobalKey());
      case FlContainerClassname.CUSTOM_CONTAINER:
        continue alsoDefault;

      // Components
      case FlComponentClassname.BUTTON:
        return FlButtonWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.TOGGLE_BUTTON:
        return FlToggleButtonWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.LABEL:
        return FlLabelWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.TEXT_FIELD:
        return FlTextFieldWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.TEXT_AREA:
        return FlTextAreaWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.ICON:
        return FlIconWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.POPUP_MENU:
        continue alsoDefault;
      case FlComponentClassname.MENU_ITEM:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU_BUTTON:
        continue alsoDefault;
      case FlComponentClassname.CHECK_BOX:
        return FlCheckBoxWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.PASSWORD_FIELD:
        return FlPasswordFieldWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.TABLE:
        return FlTableWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.RADIO_BUTTON:
        return FlRadioButtonWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.MAP:
        return FlMapWrapper(id: model.id, key: GlobalKey());
      case FlComponentClassname.CHART:
        continue alsoDefault;
      case FlComponentClassname.GAUGE:
        continue alsoDefault;

      // Cell editors:
      case FlComponentClassname.EDITOR:
        return FlEditorWrapper(id: model.id, key: GlobalKey());

      alsoDefault:
      default:
        return FlDummyWrapper(id: model.id, key: GlobalKey());
    }
  }
}
