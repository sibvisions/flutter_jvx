/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/widgets.dart';

import '../custom/custom_component.dart';
import '../model/component/fl_component_model.dart';
import '../service/api/shared/fl_component_classname.dart';
import 'button/fl_button_wrapper.dart';
import 'button/popup_menu/fl_popup_menu_button_wrapper.dart';
import 'button/radio/fl_radio_button_wrapper.dart';
import 'button/toggle/fl_toggle_button_wrapper.dart';
import 'chart/fl_chart_wrapper.dart';
import 'check_box/fl_check_box_wrapper.dart';
import 'custom/fl_custom_wrapper.dart';
import 'dummy/fl_dummy_wrapper.dart';
import 'editor/fl_editor_wrapper.dart';
import 'editor/password_field/fl_password_field_wrapper.dart';
import 'editor/text_area/fl_text_area_wrapper.dart';
import 'editor/text_field/fl_text_field_wrapper.dart';
import 'gauge/fl_gauge_wrapper.dart';
import 'icon/fl_icon_wrapper.dart';
import 'label/fl_label_wrapper.dart';
import 'map/fl_map_wrapper.dart';
import 'panel/fl_panel_wrapper.dart';
import 'panel/group/fl_group_panel_wrapper.dart';
import 'panel/scroll/fl_scroll_panel_wrapper.dart';
import 'panel/split/fl_split_panel_wrapper.dart';
import 'panel/tabset/fl_tab_panel_wrapper.dart';
import 'signature_pad/fl_signature_pad_wrapper.dart';
import 'table/fl_table_wrapper.dart';
import 'tree/fl_tree_wrapper.dart';

abstract class ComponentsFactory {
  static Widget buildWidget(FlComponentModel model) {
    switch (model.className) {
      // Containers
      case FlContainerClassname.PANEL:
      case FlContainerClassname.DESKTOP_PANEL:
      case FlContainerClassname.TOOLBAR_PANEL:
        return FlPanelWrapper(model: model as FlPanelModel, key: GlobalObjectKey(model.id));
      case FlContainerClassname.GROUP_PANEL:
        return FlGroupPanelWrapper(model: model as FlGroupPanelModel, key: GlobalObjectKey(model.id));
      case FlContainerClassname.SCROLL_PANEL:
        return FlScrollPanelWrapper(model: model as FlPanelModel, key: GlobalObjectKey(model.id));
      case FlContainerClassname.SPLIT_PANEL:
        return FlSplitPanelWrapper(model: model as FlSplitPanelModel, key: GlobalObjectKey(model.id));
      case FlContainerClassname.TABSET_PANEL:
        return FlTabPanelWrapper(model: model as FlTabPanelModel, key: GlobalObjectKey(model.id));
      case FlContainerClassname.CUSTOM_CONTAINER:
        switch (model.classNameEventSourceRef) {
          case "SignaturePad":
            return FlSignaturePadWrapper(model: model as FlCustomContainerModel, key: GlobalObjectKey(model.id));
        }
        continue alsoDefault;

      // Components
      case FlComponentClassname.BUTTON:
        return FlButtonWrapper(model: model as FlButtonModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.TOGGLE_BUTTON:
        return FlToggleButtonWrapper(model: model as FlToggleButtonModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.LABEL:
        return FlLabelWrapper(model: model as FlLabelModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.TEXT_FIELD:
        return FlTextFieldWrapper(model: model as FlTextFieldModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.TEXT_AREA:
        return FlTextAreaWrapper(model: model as FlTextAreaModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.ICON:
        return FlIconWrapper(model: model as FlIconModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.POPUP_MENU:
        continue alsoDefault;
      case FlComponentClassname.MENU_ITEM:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU_BUTTON:
        return FlPopupMenuButtonWrapper(model: model as FlPopupMenuButtonModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.CHECK_BOX:
        return FlCheckBoxWrapper(model: model as FlCheckBoxModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.PASSWORD_FIELD:
        return FlPasswordFieldWrapper(model: model as FlTextFieldModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.TABLE:
        return FlTableWrapper(model: model as FlTableModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.RADIO_BUTTON:
        return FlRadioButtonWrapper(model: model as FlRadioButtonModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.MAP:
        return FlMapWrapper(model: model as FlMapModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.CHART:
        return FlChartWrapper(model: model as FlChartModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.GAUGE:
        return FlGaugeWrapper(model: model as FlGaugeModel, key: GlobalObjectKey(model.id));
      case FlComponentClassname.TREE:
        return FlTreeWrapper(model: model as FlTreeModel, key: GlobalObjectKey(model.id));

      // Cell editors:
      case FlComponentClassname.EDITOR:
        return FlEditorWrapper(model: model as FlEditorModel, key: GlobalObjectKey(model.id));

      alsoDefault:
      default:
        return FlDummyWrapper(model: model as FlDummyModel, key: GlobalObjectKey(model.id));
    }
  }

  /// Used for replace components
  static buildCustomWidget(FlComponentModel pModel, CustomComponent pCustomComponent) {
    return FlCustomWrapper(model: pModel, key: GlobalObjectKey(pModel.id), customComponent: pCustomComponent);
  }
}
