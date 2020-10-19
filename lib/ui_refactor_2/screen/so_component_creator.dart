import 'package:flutter/material.dart';
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

  Map<String, ComponentWidget Function(ChangedComponent changedComponent)>
      standardComponents = {
    'Panel': (ChangedComponent changedComponent) => CoPanelWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: ContainerComponentModel(
              changedComponent: changedComponent,
              componentId: changedComponent.id),
        ),
    'ScrollPanel': (ChangedComponent changedComponent) => CoScrollPanelWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: ContainerComponentModel(
              changedComponent: changedComponent,
              componentId: changedComponent.id),
        ),
    'Label': (ChangedComponent changedComponent) => CoLabelWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          text: '',
          componentModel: ComponentModel(changedComponent),
        ),
    'Button': (ChangedComponent changedComponent) => CoButtonWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: ComponentModel(changedComponent),
        ),
    'Table': (ChangedComponent changedComponent) => CoTableWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: EditorComponentModel(changedComponent),
        ),
    'CheckBox': (ChangedComponent changedComponent) => CoCheckBoxWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: ComponentModel(changedComponent),
        ),
    'RadioButton': (ChangedComponent changedComponent) => CoRadioButtonWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: ComponentModel(changedComponent),
        ),
    'TextArea': (ChangedComponent changedComponent) => CoTextAreaWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: ComponentModel(changedComponent),
        ),
    'TextField': (ChangedComponent changedComponent) => CoTextFieldWidget(
          // key: GlobalKey(debugLabel: changedComponent.id),
          // key: Key(changedComponent.id),
          // key: ValueKey(changedComponent.id),
          componentModel: ComponentModel(changedComponent),
        ),
    'PasswordField': (ChangedComponent changedComponent) =>
        CoPasswordFieldWidget(
          componentModel: ComponentModel(changedComponent),
        ),
    'Icon': (ChangedComponent changedComponent) => CoIconWidget(
          componentModel: ComponentModel(changedComponent),
        )
  };

  Map<String, CoCellEditorWidget Function(CellEditor cellEditor)>
      standardCellEditors = {
    'CheckBoxCellEditor': (CellEditor cellEditor) => CoCheckboxCellEditorWidget(
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
  ComponentWidget createComponent(ChangedComponent changedComponent) {
    ComponentWidget componentWidget;

    if (changedComponent?.className?.isNotEmpty ?? true) {
      if (changedComponent.className == 'Editor') {
        componentWidget = _createEditor(changedComponent);
      } else if (changedComponent.className == null ||
          this.standardComponents[changedComponent.className] == null) {
        componentWidget = _createDefaultComponent(changedComponent);
      } else {
        componentWidget = this
            .standardComponents[changedComponent.className](changedComponent);
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

  CoEditorWidget _createEditor(ChangedComponent changedComponent) {
    CoEditorWidget editor = CoEditorWidget(
      key: GlobalKey(debugLabel: changedComponent.id),
      cellEditor: createCellEditor(changedComponent.cellEditor),
      componentModel: EditorComponentModel(changedComponent),
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

  CoEditorWidget createEditorForTable(CellEditor toCreatecellEditor,
      dynamic value, bool editable, int indexInTable) {
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
      key: ValueKey(cellEditor),
      cellEditor: cellEditor,
      componentModel: EditorComponentModel.withoutChangedComponent(
          false, editable, false, null, null, indexInTable, value),
    );

    return editor;
  }
}
