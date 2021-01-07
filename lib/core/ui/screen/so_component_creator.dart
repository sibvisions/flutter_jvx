import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/component/co_map_component_widget.dart';
import 'package:jvx_flutterclient/core/ui/component/co_toggle_button_widget.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/checkbox_cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/choice_cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/image_cell_editor_model.dart';
import 'package:uuid/uuid.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/editor/cell_editor.dart';
import '../component/co_button_widget.dart';
import '../component/co_checkbox_widget.dart';
import '../component/co_icon_widget.dart';
import '../component/co_label_widget.dart';
import '../component/co_password_field_widget.dart';
import '../component/co_radio_button_widget.dart';
import '../component/co_table_widget.dart';
import '../component/co_text_area_widget.dart';
import '../component/co_text_field_widget.dart';
import '../component/co_toggle_button_widget.dart';
import '../component/component_widget.dart';
import '../component/models/component_model.dart';
import '../component/models/label_component_model.dart';
import '../component/popup_menu/co_menu_item_widget.dart';
import '../component/popup_menu/co_popup_menu_button_widget.dart';
import '../component/popup_menu/co_popup_menu_widget.dart';
import '../container/co_group_panel_widget.dart';
import '../container/co_panel_widget.dart';
import '../container/co_scroll_panel_widget.dart';
import '../container/co_split_panel_widget.dart';
import '../container/tabset_panel/co_tabset_panel_widget.dart';
import '../editor/celleditor/co_cell_editor_widget.dart';
import '../editor/celleditor/co_checkbox_cell_editor_widget.dart';
import '../editor/celleditor/co_choice_cell_editor_widget.dart';
import '../editor/celleditor/co_date_cell_editor_widget.dart';
import '../editor/celleditor/co_image_cell_editor_widget.dart';
import '../editor/celleditor/co_linked_cell_editor_widget.dart';
import '../editor/celleditor/co_number_cell_editor_widget.dart';
import '../editor/celleditor/co_text_cell_editor_widget.dart';
import '../editor/celleditor/models/cell_editor_model.dart';
import '../editor/celleditor/models/checkbox_cell_editor_model.dart';
import '../editor/celleditor/models/choice_cell_editor_model.dart';
import '../editor/celleditor/models/date_cell_editor_model.dart';
import '../editor/celleditor/models/linked_cell_editor_model.dart';
import '../editor/celleditor/models/number_cell_editor_model.dart';
import '../editor/celleditor/models/text_cell_editor_model.dart';
import '../editor/co_editor_widget.dart';
import '../editor/editor_component_model.dart';
import 'i_component_creator.dart';
import 'so_component_data.dart';

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
        ),
    'ToggleButton': (ComponentModel componentModel) => CoToggleButtonWidget(
          componentModel: componentModel,
        ),
    'Map': (ComponentModel componentModel) => CoMapComponentWidget(
          componentModel: componentModel,
        )
  };

  Map<String, CoCellEditorWidget Function(CellEditor cellEditor)>
      standardCellEditors = {
    'CheckBoxCellEditor': (CellEditor cellEditor) => CoCheckboxCellEditorWidget(
          // key: GlobalKey(),
          cellEditorModel: CheckBoxCellEditorModel(cellEditor),
        ),
    'TextCellEditor': (CellEditor cellEditor) => CoTextCellEditorWidget(
          cellEditorModel: TextCellEditorModel(cellEditor),
        ),
    'NumberCellEditor': (CellEditor cellEditor) => CoNumberCellEditorWidget(
          cellEditorModel: NumberCellEditorModel(cellEditor),
        ),
    'ImageViewer': (CellEditor cellEditor) => CoImageCellEditorWidget(
          cellEditorModel: ImageCellEditorModel(cellEditor),
        ),
    'ChoiceCellEditor': (CellEditor cellEditor) => CoChoiceCellEditorWidget(
          cellEditorModel: ChoiceCellEditorModel(cellEditor),
        ),
    'DateCellEditor': (CellEditor cellEditor) => CoDateCellEditorWidget(
          cellEditorModel: DateCellEditorModel(cellEditor),
        ),
    'LinkedCellEditor': (CellEditor cellEditor) => CoLinkedCellEditorWidget(
          cellEditorModel: LinkedCellEditorModel(cellEditor),
        ),
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
    LabelComponentModel model = LabelComponentModel(changedComponent);
    model.text = "Undefined Component '" +
        (changedComponent.className != null ? changedComponent.className : "") +
        "'!";
    ComponentWidget componentWidget = CoLabelWidget(
      componentModel: LabelComponentModel(changedComponent),
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

  CoCellEditorWidget createCellEditorForTable(
      CellEditor toCreatecellEditor, SoComponentData data) {
    CoCellEditorWidget cellEditor;
    switch (toCreatecellEditor.className) {
      case "DateCellEditor":
        {
          cellEditor = CoDateCellEditorWidget(
            cellEditorModel: DateCellEditorModel(toCreatecellEditor)
              ..isTableView = true,
          );
        }
        break;
      case "ChoiceCellEditor":
        {
          cellEditor = CoChoiceCellEditorWidget(
            cellEditorModel: ChoiceCellEditorModel(toCreatecellEditor)
              ..isTableView = true,
          );
        }
        break;
      case "CheckBoxCellEditor":
        {
          cellEditor = CoCheckboxCellEditorWidget(
              cellEditorModel: CheckBoxCellEditorModel(toCreatecellEditor)
                ..isTableView = true);
        }
        break;
      case "LinkedCellEditor":
        {
          cellEditor = CoLinkedCellEditorWidget(
            cellEditorModel: LinkedCellEditorModel(toCreatecellEditor)
              ..isTableView = true
              ..referencedData = data,
          );
        }
        break;
    }

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
            cellEditorModel: DateCellEditorModel(toCreatecellEditor)
              ..isTableView = true
              ..editable = editable
              ..cellEditorValue = value,
          );
        }
        break;
      case "ChoiceCellEditor":
        {
          cellEditor = CoChoiceCellEditorWidget(
              cellEditorModel: ChoiceCellEditorModel(toCreatecellEditor)
                ..isTableView = true
                ..editable = editable
                ..cellEditorValue = value);
        }
        break;
      case "CheckBoxCellEditor":
        {
          cellEditor = CoCheckboxCellEditorWidget(
              cellEditorModel: CheckBoxCellEditorModel(toCreatecellEditor)
                ..isTableView = true
                ..editable = editable
                ..cellEditorValue = value);
        }
        break;
      case "LinkedCellEditor":
        {
          cellEditor = CoLinkedCellEditorWidget(
            cellEditorModel: LinkedCellEditorModel(toCreatecellEditor)
              ..isTableView = true
              ..editable = editable
              ..cellEditorValue = value
              ..referencedData = data,
          );
        }
    }

    if (cellEditor == null) return null;

    EditorComponentModel componentModel =
        EditorComponentModel.withoutChangedComponent(
            value, columnName, indexInTable, null, editable);

    CoEditorWidget editor = CoEditorWidget(
      key: ValueKey(uuid.v4()),
      cellEditor: cellEditor,
      componentModel: componentModel,
    );

    componentModel.data = data;

    return editor;
  }

  void replaceComponent(
      String className, ComponentWidget Function(ComponentModel) closure) {
    this.standardComponents[className] = closure;
  }

  void replaceCellEditor(
      String className, CoCellEditorWidget Function(CellEditor) closure) {
    this.standardCellEditors[className] = closure;
  }
}
