import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/popup_menu/co_menu_item_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/popup_menu/co_popup_menu_button_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/popup_menu/co_popup_menu_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_group_panel_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_split_panel_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/tabset_panel/co_tabset_panel_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/so_component_data.dart';
import 'package:uuid/uuid.dart';

import '../../model/cell_editor.dart';
import '../../model/changed_component.dart';
import '../component/co_button_widget.dart';
import '../component/co_checkbox_widget.dart';
import '../component/co_icon_widget.dart';
import '../component/co_label_widget.dart';
import '../component/co_password_field_widget.dart';
import '../component/co_radio_button_widget.dart';
import '../component/co_table_widget.dart';
import '../component/co_text_area_widget.dart';
import '../component/co_text_field_widget.dart';
import '../component/component_model.dart';
import '../component/component_widget.dart';
import '../container/co_panel_widget.dart';
import '../container/co_scroll_panel_widget.dart';
import '../container/container_component_model.dart';
import '../editor/celleditor/cell_editor_model.dart';
import '../editor/celleditor/co_cell_editor_widget.dart';
import '../editor/celleditor/co_checkbox_cell_editor_widget.dart';
import '../editor/celleditor/co_choice_cell_editor_widget.dart';
import '../editor/celleditor/co_date_cell_editor_widget.dart';
import '../editor/celleditor/co_image_cell_editor_widget.dart';
import '../editor/celleditor/co_linked_cell_editor_widget.dart';
import '../editor/celleditor/co_number_cell_editor_widget.dart';
import '../editor/celleditor/co_text_cell_editor_widget.dart';
import '../editor/co_editor_widget.dart';
import '../editor/editor_component_model.dart';
import 'i_component_creator.dart';

class SoComponentCreator implements IComponentCreator {
  BuildContext context;

  static final Uuid uuid = Uuid();

  SoComponentCreator([this.context]);

  Map<String, ComponentWidget Function(ComponentModel componentModel)>
      standardComponents = {
    'Panel': (ComponentModel componentModel) => CoPanelWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: componentModel,
        ),
    'ScrollPanel': (ComponentModel componentModel) => CoScrollPanelWidget(
        // key: GlobalKey(debugLabel: changedComponent.id),
        // key: Key(changedComponent.id),
        // key: ValueKey(changedComponent.id),
        componentModel: componentModel),
    'GroupPanel': (ComponentModel componentModel) =>
        CoGroupPanelWidget(componentModel: componentModel),
    'TabsetPanel': (ComponentModel componentModel) => CoTabsetPanelWidget(
          componentModel: componentModel,
        ),
    'SplitPanel': (ComponentModel componentModel) => CoSplitPanelWidget(
          componentModel: componentModel,
        ),
    'Label': (ComponentModel componentModel) => CoLabelWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          text: '',
          componentModel: componentModel,
        ),
    'Button': (ComponentModel componentModel) => CoButtonWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: componentModel,
        ),
    'Table': (ComponentModel componentModel) => CoTableWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: componentModel,
        ),
    'CheckBox': (ComponentModel componentModel) => CoCheckBoxWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: componentModel,
        ),
    'RadioButton': (ComponentModel componentModel) => CoRadioButtonWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: componentModel,
        ),
    'TextArea': (ComponentModel componentModel) => CoTextAreaWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: componentModel,
        ),
    'TextField': (ComponentModel componentModel) => CoTextFieldWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: componentModel,
        ),
    'PasswordField': (ComponentModel componentModel) => CoPasswordFieldWidget(
          componentModel: componentModel,
        ),
    'Icon': (ComponentModel componentModel) => CoIconWidget(
          componentModel: componentModel,
        ),
    'PopupMenu': (ComponentModel componentModel) => CoPopupMenuWidget(
          componentModel: componentModel,
        ),
    'MenuItem': (ComponentModel componentModel) => CoMenuItemWidget(
          componentModel: componentModel,
        ),
    'PopupMenuButton': (ComponentModel componentModel) =>
        CoPopupMenuButtonWidget(
          componentModel: componentModel,
        )
  };

  Map<String, CoCellEditorWidget Function(CellEditor cellEditor)>
      standardCellEditors = {
    'CheckBoxCellEditor': (CellEditor cellEditor) => CoCheckboxCellEditorWidget(
          // key: GlobalKey(),
          changedCellEditor: cellEditor,
          cellEditorModel: CellEditorModel(cellEditor),
        ),
    'TextCellEditor': (CellEditor cellEditor) => CoTextCellEditorWidget(
          changedCellEditor: cellEditor,
          cellEditorModel: CellEditorModel(cellEditor),
        ),
    'NumberCellEditor': (CellEditor cellEditor) => CoNumberCellEditorWidget(
          changedCellEditor: cellEditor,
          cellEditorModel: CellEditorModel(cellEditor),
        ),
    'ImageViewer': (CellEditor cellEditor) => CoImageCellEditorWidget(
          changedCellEditor: cellEditor,
          cellEditorModel: CellEditorModel(cellEditor),
        ),
    'ChoiceCellEditor': (CellEditor cellEditor) => CoChoiceCellEditorWidget(
          changedCellEditor: cellEditor,
          cellEditorModel: CellEditorModel(cellEditor),
        ),
    'DateCellEditor': (CellEditor cellEditor) => CoDateCellEditorWidget(
          changedCellEditor: cellEditor,
          cellEditorModel: CellEditorModel(cellEditor),
        ),
    'LinkedCellEditor': (CellEditor cellEditor) => CoLinkedCellEditorWidget(
          changedCellEditor: cellEditor,
          cellEditorModel: CellEditorModel(cellEditor),
        )
  };

  @override
  ComponentWidget createComponent(ComponentModel componentModel) {
    ComponentWidget componentWidget;

    if (componentModel.changedComponent?.className?.isNotEmpty ?? true) {
      if (componentModel.changedComponent?.className == 'Editor') {
        componentWidget = _createEditor(componentModel);
      } else if (componentModel.changedComponent.className == null ||
          this.standardComponents[componentModel.changedComponent.className] ==
              null) {
        componentWidget =
            _createDefaultComponent(componentModel.changedComponent);
      } else {
        componentWidget =
            this.standardComponents[componentModel.changedComponent.className](
                componentModel);
      }
    }

    return componentWidget;
  }

  ComponentWidget _createDefaultComponent(ChangedComponent changedComponent) {
    ComponentWidget componentWidget = CoLabelWidget(
      text: "Undefined Component '" +
          (changedComponent.className != null
              ? changedComponent.className
              : "") +
          "'!",
      componentModel: ComponentModel(changedComponent),
    );

    return componentWidget;
  }

  CoEditorWidget _createEditor(ComponentModel componentModel) {
    CoEditorWidget editor = CoEditorWidget(
      // key: GlobalKey(debugLabel: changedComponent.id),
      cellEditor: createCellEditor(componentModel.changedComponent.cellEditor),
      componentModel: componentModel,
    );
    return editor;
  }

  CoCellEditorWidget createCellEditor(CellEditor toCreatecellEditor) {
    CoCellEditorWidget cellEditor;

    if (toCreatecellEditor == null) {
      cellEditor = null;
    } else {
      cellEditor = this.standardCellEditors[toCreatecellEditor.className](
          toCreatecellEditor);
    }

    return cellEditor;
  }

  CoCellEditorWidget createCellEditorForTable(CellEditor toCreatecellEditor) {
    CoCellEditorWidget cellEditor;
    switch (toCreatecellEditor.className) {
      case "DateCellEditor":
        {
          cellEditor = CoDateCellEditorWidget(
            changedCellEditor: toCreatecellEditor,
            cellEditorModel: CellEditorModel(toCreatecellEditor),
          );
        }
        break;
      case "ChoiceCellEditor":
        {
          cellEditor = CoChoiceCellEditorWidget(
            changedCellEditor: toCreatecellEditor,
            cellEditorModel: CellEditorModel(toCreatecellEditor),
          );
        }
        break;
      case "CheckBoxCellEditor":
        {
          cellEditor = CoCheckboxCellEditorWidget(
              changedCellEditor: toCreatecellEditor,
              cellEditorModel: CellEditorModel(toCreatecellEditor));
        }
        break;
    }

    // cellEditor?.isTableView = true;

    return cellEditor;
  }

  CoEditorWidget createEditorForTable(
      CellEditor toCreatecellEditor,
      dynamic value,
      bool editable,
      int indexInTable,
      SoComponentData data,
      String columnName) {
    CoCellEditorWidget cellEditor;
    switch (toCreatecellEditor.className) {
      case "DateCellEditor":
        {
          cellEditor = CoDateCellEditorWidget(
              cellEditorModel: CellEditorModel(toCreatecellEditor),
              changedCellEditor: toCreatecellEditor);
        }
        break;
      case "ChoiceCellEditor":
        {
          cellEditor = CoChoiceCellEditorWidget(
              cellEditorModel: CellEditorModel(toCreatecellEditor),
              changedCellEditor: toCreatecellEditor);
        }
        break;
      case "CheckBoxCellEditor":
        {
          cellEditor = CoCheckboxCellEditorWidget(
              cellEditorModel: CellEditorModel(toCreatecellEditor),
              changedCellEditor: toCreatecellEditor);
        }
        break;
    }

    if (cellEditor == null) return null;

    CoEditorWidget editor = CoEditorWidget(
      // key: GlobalKey(debugLabel: uuid.v4()),
      data: data,
      key: ValueKey(uuid.v4()),
      cellEditor: cellEditor,
      componentModel: EditorComponentModel.withoutChangedComponent(false,
          editable, false, null, null, indexInTable, value, columnName, null),
    );

    return editor;
  }
}
