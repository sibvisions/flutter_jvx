import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/container/i_container.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_group_panel.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_scroll_panel.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_split_panel.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/i_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_checkbox_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_image_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_lazy_table.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_table.dart';
import 'package:jvx_mobile_v3/ui/screen/i_component_creator.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_flow_layout.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_form_layout.dart';
import '../component/jvx_button.dart';
import '../editor/celleditor/jvx_choice_cell_editor.dart';
import '../editor/celleditor/jvx_date_cell_editor.dart';
import '../editor/celleditor/jvx_linked_cell_editor.dart';
import '../editor/celleditor/jvx_number_cell_editor.dart';
import '../editor/celleditor/jvx_text_cell_editor.dart';
import '../editor/jvx_editor.dart';
import '../layout/i_layout.dart';
import '../layout/jvx_border_layout.dart';
import '../../model/changed_component.dart';
import 'package:flutter/material.dart';
import '../container/jvx_panel.dart';
import '../component/jvx_label.dart';

class ComponentCreator implements IComponentCreator {
  BuildContext context;

  ComponentCreator([this.context]);

  IComponent createComponent(ChangedComponent changedComponent) {
    IComponent component;

    if (changedComponent?.className?.isNotEmpty ?? true) {
      switch (changedComponent.className) {
        case "Panel":         { component = new JVxPanel(Key(changedComponent.id), context); } break; 
        case "GroupPanel":    { component = new JVxGroupPanel(Key(changedComponent.id), context); } break; 
        case "ScrollPanel":   { component = new JVxScrollPanel(Key(changedComponent.id), context); } break; 
        case "SplitPanel":    { component = new JVxSplitPanel(Key(changedComponent.id), context); } break; 
        case "Label":         { component = new JVxLabel(Key(changedComponent.id), context); } break; 
        case "Button":        { component = new JVxButton(Key(changedComponent.id), context); } break; 
        case "Table":         { component = new JVxLazyTable(Key(changedComponent.id), context); } break;
        case "Editor":        { component = _createEditor(changedComponent); } break;
        default:              { component = _createDefaultComponent(changedComponent); } break;
      }
    }

    if (component is IContainer)
      component.layout = _createLayout(changedComponent);

    component?.updateProperties(changedComponent);

    return component;
  }



  ILayout _createLayout(ChangedComponent changedComponent) {
    if (changedComponent.hasProperty(ComponentProperty.LAYOUT)) {
      String layoutRaw = changedComponent.getProperty<String>(ComponentProperty.LAYOUT);
      String layoutData = changedComponent.getProperty<String>(ComponentProperty.LAYOUT_DATA);

      switch (changedComponent.layoutName) {
        case "BorderLayout": { return JVxBorderLayout.fromLayoutString(layoutRaw, layoutData); } break; 
        case "FormLayout": { return JVxFormLayout.fromLayoutString(layoutRaw, layoutData); } break; 
        case "FlowLayout": { return  JVxFlowLayout.fromLayoutString(layoutRaw, layoutData); } break;
      }
    }

    return null;
  }


  ICellEditor createCellEditor(CellEditor toCreatecellEditor) {
    ICellEditor cellEditor;

    switch (toCreatecellEditor.className) {
      case "TextCellEditor":     { cellEditor = JVxTextCellEditor(toCreatecellEditor, context); } break;
      case "NumberCellEditor":   { cellEditor = JVxNumberCellEditor(toCreatecellEditor, context); } break;
      case "LinkedCellEditor":   { cellEditor = JVxLinkedCellEditor(toCreatecellEditor, context); } break; 
      case "DateCellEditor":     { cellEditor = JVxDateCellEditor(toCreatecellEditor, context); } break; 
      case "ImageViewer":        { cellEditor = JVxImageCellEditor(toCreatecellEditor, context); } break; 
      case "ChoiceCellEditor":   { cellEditor = JVxChoiceCellEditor(toCreatecellEditor, context); } break;
      case "CheckBoxCellEditor": { cellEditor = JVxCheckboxCellEditor(toCreatecellEditor, context); } break;
    }

    //cellEditor.dataProvider = changedComponent.getProperty<String>(ComponentProperty.DATA_PROVIDER);
    //cellEditor.columnName = changedComponent.getProperty<String>(ComponentProperty.COLUMN_NAME);

    return cellEditor;
  }

  JVxEditor _createEditor(ChangedComponent changedComponent) {
    JVxEditor editor = new JVxEditor(Key(changedComponent.id), context);
    editor.cellEditor = createCellEditor(changedComponent.cellEditor);
    return editor;
  }

  IComponent _createDefaultComponent(ChangedComponent changedComponent) {
    JVxLabel component = new JVxLabel(Key(changedComponent.id), context);
    component.text = "Undefined Component '" + (changedComponent.className!=null?changedComponent.className:"") + "'!";
    return component;
  }

}