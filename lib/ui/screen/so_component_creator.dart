import 'package:jvx_flutterclient/ui/editor/celleditor/co_cell_editor.dart';

import '../component/co_menu_item.dart';
import '../component/co_popup_menu.dart';
import '../component/co_icon.dart';
import '../component/co_popup_menu_button.dart';
import '../component/co_textarea.dart';
import '../component/co_passwordfield.dart';
import '../component/co_radiobutton.dart';
import '../component/co_textfield.dart';
import '../../model/cell_editor.dart';
import '../../model/properties/component_properties.dart';
import '../component/i_component.dart';
import '../component/co_checkbox.dart';
import '../container/i_container.dart';
import '../container/co_group_panel.dart';
import '../container/co_scroll_panel.dart';
import '../container/co_split_panel.dart';
import '../editor/celleditor/i_cell_editor.dart';
import '../editor/celleditor/co_checkbox_cell_editor.dart';
import '../editor/celleditor/co_image_cell_editor.dart';
import '../component/co_table.dart';
import '../layout/co_flow_layout.dart';
import '../layout/co_grid_layout.dart';
import 'i_component_creator.dart';
import '../layout/co_form_layout.dart';
import '../component/co_button.dart';
import '../editor/celleditor/co_choice_cell_editor.dart';
import '../editor/celleditor/co_date_cell_editor.dart';
import '../editor/celleditor/co_linked_cell_editor.dart';
import '../editor/celleditor/co_number_cell_editor.dart';
import '../editor/celleditor/co_text_cell_editor.dart';
import '../editor/co_editor.dart';
import '../layout/i_layout.dart';
import '../layout/co_border_layout.dart';
import '../../model/changed_component.dart';
import 'package:flutter/material.dart';
import '../container/co_panel.dart';
import '../component/co_label.dart';

class SoComponentCreator implements IComponentCreator {
  BuildContext context;

  Map<String, Object Function(GlobalKey globalKey, BuildContext context)>
      standardComponents = {
    'Panel': (GlobalKey globalKey, BuildContext context) =>
        CoPanel(globalKey, context),
    'GroupPanel': (GlobalKey globalKey, BuildContext context) =>
        CoGroupPanel(globalKey, context),
    'ScrollPanel': (GlobalKey globalKey, BuildContext context) =>
        CoScrollPanel(globalKey, context),
    'SplitPanel': (GlobalKey globalKey, BuildContext context) =>
        CoSplitPanel(globalKey, context),
    'Label': (GlobalKey globalKey, BuildContext context) =>
        CoLabel(globalKey, context),
    'Button': (GlobalKey globalKey, BuildContext context) =>
        CoButton(globalKey, context),
    'Table': (GlobalKey globalKey, BuildContext context) =>
        CoTable(globalKey, context),
    'CheckBox': (GlobalKey globalKey, BuildContext context) =>
        CoCheckbox(globalKey, context),
    'RadioButton': (GlobalKey globalKey, BuildContext context) =>
        CoRadioButton(globalKey, context),
    'PopupMenuButton': (GlobalKey globalKey, BuildContext context) =>
        CoPopupMenuButton(globalKey, context),
    'TextField': (GlobalKey globalKey, BuildContext context) =>
        CoTextField(globalKey, context),
    'PasswordField': (GlobalKey globalKey, BuildContext context) =>
        CoPasswordField(globalKey, context),
    'TextArea': (GlobalKey globalKey, BuildContext context) =>
        CoTextArea(globalKey, context),
    'Icon': (GlobalKey globalKey, BuildContext context) =>
        CoIcon(globalKey, context),
    'PopupMenu': (GlobalKey globalKey, BuildContext context) =>
        CoPopupMenu(globalKey, context),
    'MenuItem': (GlobalKey globalKey, BuildContext context) =>
        CoMenuItem(globalKey, context),
  };

  Map<String, Object Function(CellEditor cellEditor, BuildContext context)>
      standardCellEditors = {
    'TextCellEditor': (CellEditor cellEditor, BuildContext context) =>
        CoTextCellEditor(cellEditor, context),
    'NumberCellEditor': (CellEditor cellEditor, BuildContext context) =>
        CoNumberCellEditor(cellEditor, context),
    'LinkedCellEditor': (CellEditor cellEditor, BuildContext context) =>
        CoLinkedCellEditor(cellEditor, context),
    'DateCellEditor': (CellEditor cellEditor, BuildContext context) =>
        CoDateCellEditor(cellEditor, context),
    'ImageViewer': (CellEditor cellEditor, BuildContext context) =>
        CoImageCellEditor(cellEditor, context),
    'ChoiceCellEditor': (CellEditor cellEditor, BuildContext context) =>
        CoChoiceCellEditor(cellEditor, context),
    'CheckBoxCellEditor': (CellEditor cellEditor, BuildContext context) =>
        CoCheckboxCellEditor(cellEditor, context),
  };

  SoComponentCreator([this.context]);

  /// Method for setting the standard component for the respective jvx component
  setStandardComponent(String key,
      Object Function(GlobalKey globalKey, BuildContext context) value) {
    this.standardComponents[key] = value;
  }

  /// Method for setting the standard celleditor for the respective jvx celleditor
  setStandardCellEditors(String key,
      Object Function(CellEditor cellEditor, BuildContext context) value) {
    this.standardCellEditors[key] = value;
  }

  IComponent createComponent(ChangedComponent changedComponent) {
    IComponent component;

    if (changedComponent?.className?.isNotEmpty ?? true) {
      if (changedComponent.className == 'Editor') {
        component = _createEditor(changedComponent);
      } else {
        component = this.standardComponents[changedComponent.className](
            GlobalKey(debugLabel: changedComponent.id), context);
      }

      if (component == null) {
        component = _createDefaultComponent(changedComponent);
      }
    }

    component?.updateProperties(changedComponent);

    if (component is IContainer)
      component.layout = _createLayout(component, changedComponent);

    return component;
  }

  ILayout _createLayout(
      IContainer container, ChangedComponent changedComponent) {
    if (changedComponent.hasProperty(ComponentProperty.LAYOUT)) {
      String layoutRaw =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT);
      String layoutData =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT_DATA);

      switch (changedComponent.layoutName) {
        case "BorderLayout":
          {
            return CoBorderLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "FormLayout":
          {
            return CoFormLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "FlowLayout":
          {
            return CoFlowLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "GridLayout":
          {
            return CoGridLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
      }
    }

    return null;
  }

  ICellEditor createCellEditor(CellEditor toCreatecellEditor) {
    ICellEditor cellEditor;

    if (toCreatecellEditor == null) {
      cellEditor = null;
    } else {
      cellEditor = this.standardCellEditors[toCreatecellEditor.className](
          toCreatecellEditor, context);
    }

    return cellEditor;
  }

  ICellEditor createCellEditorForTable(CellEditor toCreatecellEditor) {
    ICellEditor cellEditor;
    switch (toCreatecellEditor.className) {
      case "DateCellEditor":
        {
          cellEditor = CoDateCellEditor(toCreatecellEditor, context);
        }
        break;
      case "ChoiceCellEditor":
        {
          cellEditor = CoChoiceCellEditor(toCreatecellEditor, context);
        }
        break;
      case "CheckBoxCellEditor":
        {
          cellEditor = CoCheckboxCellEditor(toCreatecellEditor, context);
        }
        break;
    }

    cellEditor?.isTableView = true;

    return cellEditor;
  }

  CoEditor createEditorForTable(CellEditor toCreatecellEditor) {
    CoEditor editor = CoEditor(GlobalKey<FormState>(), context);
    ICellEditor cellEditor;
    switch (toCreatecellEditor.className) {
      case "DateCellEditor":
        {
          cellEditor = CoDateCellEditor(toCreatecellEditor, context);
        }
        break;
      case "ChoiceCellEditor":
        {
          cellEditor = CoChoiceCellEditor(toCreatecellEditor, context);
        }
        break;
      case "CheckBoxCellEditor":
        {
          cellEditor = CoCheckboxCellEditor(toCreatecellEditor, context);
        }
        break;
    }

    if (cellEditor == null) return null;

    cellEditor?.isTableView = true;
    editor.cellEditor = cellEditor;

    return editor;
  }

  CoEditor _createEditor(ChangedComponent changedComponent) {
    CoEditor editor =
        new CoEditor(GlobalKey(debugLabel: changedComponent.id), context);
    editor.cellEditor = createCellEditor(changedComponent.cellEditor);
    return editor;
  }

  IComponent _createDefaultComponent(ChangedComponent changedComponent) {
    CoLabel component =
        new CoLabel(GlobalKey(debugLabel: changedComponent.id), context);
    component.text = "Undefined Component '" +
        (changedComponent.className != null ? changedComponent.className : "") +
        "'!";
    return component;
  }
}
