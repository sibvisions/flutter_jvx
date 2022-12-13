/* Copyright 2022 SIB Visions GmbH
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

import '../model/component/fl_component_model.dart';
import '../service/api/shared/api_object_property.dart';
import '../service/api/shared/fl_component_classname.dart';
import 'component/button/fl_button_model.dart';
import 'component/button/fl_popup_menu_button_model.dart';
import 'component/button/fl_popup_menu_item_model.dart';
import 'component/button/fl_popup_menu_model.dart';
import 'component/button/fl_radio_button_model.dart';
import 'component/button/fl_separator.dart';
import 'component/button/fl_toggle_button_model.dart';
import 'component/chart/fl_chart_model.dart';
import 'component/check_box/fl_check_box_model.dart';
import 'component/custom/fl_custom_container_model.dart';
import 'component/dummy/fl_dummy_model.dart';
import 'component/editor/fl_editor_model.dart';
import 'component/editor/text_area/fl_text_area_model.dart';
import 'component/editor/text_field/fl_text_field_model.dart';
import 'component/gauge/fl_gauge_model.dart';
import 'component/icon/fl_icon_model.dart';
import 'component/label/fl_label_model.dart';
import 'component/map/fl_map_model.dart';
import 'component/panel/fl_group_panel_model.dart';
import 'component/panel/fl_panel_model.dart';
import 'component/panel/fl_split_panel_model.dart';
import 'component/panel/fl_tab_panel_model.dart';
import 'component/table/fl_table_model.dart';

abstract class ModelFactory {
  static FlComponentModel buildModel(String className) {
    switch (className) {
      // Containers
      case FlContainerClassname.PANEL:
      case FlContainerClassname.TOOLBAR_PANEL:
      case FlContainerClassname.DESKTOP_PANEL:
        return FlPanelModel();
      case FlContainerClassname.GROUP_PANEL:
        return FlGroupPanelModel();
      case FlContainerClassname.SCROLL_PANEL:
        return FlPanelModel();
      case FlContainerClassname.SPLIT_PANEL:
        return FlSplitPanelModel();
      case FlContainerClassname.TABSET_PANEL:
        return FlTabPanelModel();
      case FlContainerClassname.CUSTOM_CONTAINER:
        return FlCustomContainerModel();

      // Components
      case FlComponentClassname.BUTTON:
        return FlButtonModel();
      case FlComponentClassname.TOGGLE_BUTTON:
        return FlToggleButtonModel();
      case FlComponentClassname.LABEL:
        return FlLabelModel();
      case FlComponentClassname.TEXT_FIELD:
        return FlTextFieldModel();
      case FlComponentClassname.TEXT_AREA:
        return FlTextAreaModel();
      case FlComponentClassname.ICON:
        return FlIconModel();
      case FlComponentClassname.POPUP_MENU:
        return FlPopupMenuModel();
      case FlComponentClassname.MENU_ITEM:
        return FlPopupMenuItemModel();
      case FlComponentClassname.SEPERATOR:
        return FlSeparatorModel();
      case FlComponentClassname.POPUP_MENU_BUTTON:
        return FlPopupMenuButtonModel();
      case FlComponentClassname.CHECK_BOX:
        return FlCheckBoxModel();
      case FlComponentClassname.PASSWORD_FIELD:
        return FlTextFieldModel();
      case FlComponentClassname.TABLE:
        return FlTableModel();
      case FlComponentClassname.RADIO_BUTTON:
        return FlRadioButtonModel();
      case FlComponentClassname.MAP:
        return FlMapModel();
      case FlComponentClassname.CHART:
        return FlChartModel();
      case FlComponentClassname.GAUGE:
        return FlGaugeModel();

      // Cell editors:
      case FlComponentClassname.EDITOR:
        return FlEditorModel();

      default:
        return FlDummyModel();
    }
  }

  /// Returns a list of changed component jsons, or null if none are found.
  ///
  /// A component is only recognized as updated if the [ApiObjectProperty.className] is not supplied.
  static List<dynamic>? retrieveChangedComponents(List<dynamic>? pChangedComponents) {
    if (pChangedComponents != null) {
      List<dynamic> changedComponents = [];

      for (dynamic component in pChangedComponents) {
        if (component[ApiObjectProperty.className] == null) {
          changedComponents.add(component);
        }
      }

      if (changedComponents.isNotEmpty) {
        return changedComponents;
      }
    }
    return null;
  }

  /// Returns a list of new [FlComponentModel] models parsed from json, or null if none are found.
  ///
  /// Components with a [ApiObjectProperty.className] are considered new,
  static List<FlComponentModel>? retrieveNewComponents(List<dynamic>? pChangedComponents) {
    if (pChangedComponents != null) {
      List<FlComponentModel> models = [];
      for (dynamic changedComponent in pChangedComponents) {
        String? className = changedComponent[ApiObjectProperty.className];
        if (className != null) {
          FlComponentModel model = ModelFactory.buildModel(className);
          model.applyFromJson(changedComponent);
          models.add(model);
        }
      }
      if (models.isNotEmpty) {
        return models;
      }
    }
    return null;
  }
}
