import 'package:flutter_client/src/model/component/button/fl_radio_button_model.dart';
import 'package:flutter_client/src/model/component/editor/fl_editor_model.dart';
import 'package:flutter_client/src/model/component/map/fl_map_model.dart';
import 'package:flutter_client/src/model/component/table/fl_table_model.dart';

import '../model/component/fl_component_model.dart';
import '../service/api/shared/fl_component_classname.dart';
import 'component/button/fl_button_model.dart';
import 'component/button/fl_toggle_button_model.dart';
import 'component/check_box/fl_check_box_model.dart';
import 'component/dummy/fl_dummy_model.dart';
import 'component/editor/text_area/fl_text_area_model.dart';
import 'component/editor/text_field/fl_text_field_model.dart';
import 'component/icon/fl_icon_model.dart';
import 'component/label/fl_label_model.dart';
import 'component/panel/fl_group_panel_model.dart';
import 'component/panel/fl_panel_model.dart';
import 'component/panel/fl_split_panel_model.dart';
import 'component/panel/fl_tab_panel_model.dart';

//GlobalKey()
abstract class ModelFactory {
  static FlComponentModel buildModel(dynamic pJson, String className) {
    switch (className) {
      // Containers
      case FlContainerClassname.PANEL:
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
        continue alsoDefault;

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
        continue alsoDefault;
      case FlComponentClassname.MENU_ITEM:
        continue alsoDefault;
      case FlComponentClassname.POPUP_MENU_BUTTON:
        continue alsoDefault;
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
        continue alsoDefault;
      case FlComponentClassname.GAUGE:
        continue alsoDefault;

      // Cell editors:
      case FlComponentClassname.EDITOR:
        return FlEditorModel(json: pJson);

      alsoDefault:
      default:
        return FlDummyModel();
    }
  }
}
