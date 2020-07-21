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

  SoComponentCreator([this.context]);

  IComponent createComponent(ChangedComponent changedComponent) {
    IComponent component;

    if (changedComponent?.className?.isNotEmpty ?? true) {
      switch (changedComponent.className) {
        case "Panel":
          {
            component = new CoPanel(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "GroupPanel":
          {
            component = new CoGroupPanel(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "ScrollPanel":
          {
            component = new CoScrollPanel(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "SplitPanel":
          {
            component = new CoSplitPanel(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "Label":
          {
            component = new CoLabel(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "Button":
          {
            component = new CoButton(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "Table":
          {
            component = new CoTable(
                GlobalKey(debugLabel: changedComponent.id), context, this);
          }
          break;
        case "CheckBox":
          {
            component = new CoCheckbox(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "RadioButton":
          {
            component = new CoRadioButton(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "PopupMenuButton":
          {
            component = new CoPopupMenuButton(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "TextField":
          {
            component = new CoTextField(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "PasswordField":
          {
            component = new CoPasswordField(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "TextArea":
          {
            component = new CoTextArea(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "Icon":
          {
            component =
                new CoIcon(GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "PopupMenu":
          {
            component = new CoPopupMenu(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "MenuItem":
          {
            component = new CoMenuItem(
                GlobalKey(debugLabel: changedComponent.id), context);
          }
          break;
        case "Editor":
          {
            component = _createEditor(changedComponent);
          }
          break;
        default:
          {
            component = _createDefaultComponent(changedComponent);
          }
          break;
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

    switch (toCreatecellEditor.className) {
      case "TextCellEditor":
        {
          cellEditor = CoTextCellEditor(toCreatecellEditor, context);
        }
        break;
      case "NumberCellEditor":
        {
          cellEditor = CoNumberCellEditor(toCreatecellEditor, context);
        }
        break;
      case "LinkedCellEditor":
        {
          cellEditor = CoLinkedCellEditor(toCreatecellEditor, context);
        }
        break;
      case "DateCellEditor":
        {
          cellEditor = CoDateCellEditor(toCreatecellEditor, context);
        }
        break;
      case "ImageViewer":
        {
          cellEditor = CoImageCellEditor(toCreatecellEditor, context);
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
