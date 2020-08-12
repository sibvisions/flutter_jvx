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

  Map<String, Object Function(ComponentContext componentContext)>
      standardComponents = {
    'Panel': (ComponentContext componentContext) =>
        CoPanel(componentContext.globalKey, componentContext.context),
    'GroupPanel': (ComponentContext componentContext) =>
        CoGroupPanel(componentContext.globalKey, componentContext.context),
    'ScrollPanel': (ComponentContext componentContext) =>
        CoScrollPanel(componentContext.globalKey, componentContext.context),
    'SplitPanel': (ComponentContext componentContext) =>
        CoSplitPanel(componentContext.globalKey, componentContext.context),
    'Label': (ComponentContext componentContext) =>
        CoLabel(componentContext.globalKey, componentContext.context),
    'Button': (ComponentContext componentContext) =>
        CoButton(componentContext.globalKey, componentContext.context),
    'Table': (ComponentContext componentContext) =>
        CoTable(componentContext.globalKey, componentContext.context),
    'CheckBox': (ComponentContext componentContext) =>
        CoCheckbox(componentContext.globalKey, componentContext.context),
    'RadioButton': (ComponentContext componentContext) =>
        CoRadioButton(componentContext.globalKey, componentContext.context),
    'PopupMenuButton': (ComponentContext componentContext) =>
        CoPopupMenuButton(componentContext.globalKey, componentContext.context),
    'TextField': (ComponentContext componentContext) =>
        CoTextField(componentContext.globalKey, componentContext.context),
    'PasswordField': (ComponentContext componentContext) =>
        CoPasswordField(componentContext.globalKey, componentContext.context),
    'TextArea': (ComponentContext componentContext) =>
        CoTextArea(componentContext.globalKey, componentContext.context),
    'Icon': (ComponentContext componentContext) =>
        CoIcon(componentContext.globalKey, componentContext.context),
    'PopupMenu': (ComponentContext componentContext) =>
        CoPopupMenu(componentContext.globalKey, componentContext.context),
    'MenuItem': (ComponentContext componentContext) =>
        CoMenuItem(componentContext.globalKey, componentContext.context),
    'TextCellEditor': (ComponentContext componentContext) =>
        CoTextCellEditor(componentContext.cellEditor, componentContext.context),
    'NumberCellEditor': (ComponentContext componentContext) =>
        CoNumberCellEditor(
            componentContext.cellEditor, componentContext.context),
    'LinkedCellEditor': (ComponentContext componentContext) =>
        CoLinkedCellEditor(
            componentContext.cellEditor, componentContext.context),
    'DateCellEditor': (ComponentContext componentContext) =>
        CoDateCellEditor(componentContext.cellEditor, componentContext.context),
    'ImageViewer': (ComponentContext componentContext) => CoImageCellEditor(
        componentContext.cellEditor, componentContext.context),
    'ChoiceCellEditor': (ComponentContext componentContext) =>
        CoChoiceCellEditor(
            componentContext.cellEditor, componentContext.context),
    'CheckBoxCellEditor': (ComponentContext componentContext) =>
        CoCheckboxCellEditor(
            componentContext.cellEditor, componentContext.context),
  };

  SoComponentCreator([this.context]);

  /// Method for setting the standard component for the respective jvx component
  setStandardComponent(
      String key, Object Function(ComponentContext componentContext) value) {
    this.standardComponents[key] = value;
  }

  IComponent createComponent(ChangedComponent changedComponent) {
    IComponent component;

    if (changedComponent?.className?.isNotEmpty ?? true) {
      if (changedComponent.className == 'Editor') {
        component = _createEditor(changedComponent);
      } else {
        component = this.standardComponents[changedComponent.className](
            ComponentContext(
                globalKey: GlobalKey(debugLabel: changedComponent.id),
                context: context));
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
      cellEditor = this.standardComponents[toCreatecellEditor.className](
          ComponentContext(cellEditor: toCreatecellEditor, context: context));
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

class ComponentContext {
  final CellEditor cellEditor;
  final GlobalKey globalKey;
  final BuildContext context;

  ComponentContext({@required this.context, this.globalKey, this.cellEditor});
}
