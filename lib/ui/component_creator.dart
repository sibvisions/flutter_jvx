import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/container/i_container.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_group_panel.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_scroll_panel.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_split_panel.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/i_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_table.dart';
import 'package:jvx_mobile_v3/ui/i_component_creator.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_flow_layout.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_form_layout.dart';
import 'component/jvx_button.dart';
import 'editor/celleditor/jvx_choice_cell_editor.dart';
import 'editor/celleditor/jvx_date_cell_editor.dart';
import 'editor/celleditor/jvx_image_viewer.dart';
import 'editor/celleditor/jvx_linked_cell_editor.dart';
import 'editor/celleditor/jvx_number_cell_editor.dart';
import 'editor/celleditor/jvx_text_cell_editor.dart';
import 'editor/jvx_editor.dart';
import 'layout/i_layout.dart';
import 'layout/jvx_border_layout.dart';
import '../model/changed_component.dart';
import 'package:flutter/material.dart';
import 'container/jvx_panel.dart';
import 'component/jvx_label.dart';

class ComponentCreator implements IComponentCreator {
  BuildContext context;

  ComponentCreator(this.context);

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
        case "Table":         { component = new JVxTable(Key(changedComponent.id), context); } break;
        case "Editor":        { component = _createEditor(changedComponent); } break;
        default:              { component = _createDefaultComponent(changedComponent); } break;
      }
    }

    if (component is IContainer)
      component.layout = _createLayout(changedComponent);

    component?.updateProperties(changedComponent.componentProperties);

    if (component is JVxEditor) {
      component.initData();
    }

    return component;
  }



  ILayout _createLayout(ChangedComponent changedComponent) {

    if (changedComponent.hasLayout) {
      switch (changedComponent.layoutName) {
        case "BorderLayout": { return JVxBorderLayout.fromLayoutString(changedComponent.layoutRaw, changedComponent.layoutData); } break; 
        case "FormLayout": { return JVxFormLayout.fromLayoutString(changedComponent.layoutRaw, changedComponent.layoutData); } break; 
        case "FlowLayout": { return  JVxFlowLayout.fromLayoutString(changedComponent.layoutRaw, changedComponent.layoutData); } break;
      }
    }

    return null;
  }


  ICellEditor _createCellEditor(ChangedComponent changedComponent) {
    ICellEditor cellEditor;

    switch (changedComponent?.cellEditor?.className) {
      case "TextCellEditor":    { cellEditor = JVxTextCellEditor(changedComponent.componentProperties.cellEditorProperties, context); } break;
      case "NumberCellEditor":  { cellEditor = JVxNumberCellEditor(changedComponent.componentProperties.cellEditorProperties, context); } break;
      case "LinkedCellEditor":  { cellEditor = JVxLinkedCellEditor(changedComponent.componentProperties.cellEditorProperties, context); } break; 
      case "DateCellEditor":    { cellEditor = JVxDateCellEditor(changedComponent.componentProperties.cellEditorProperties, context); } break; 
      case "ImageViewer":       { cellEditor = JVxImageViewer(changedComponent.componentProperties.cellEditorProperties, context); } break; 
      case "ChoiceCellEditor":  { cellEditor = JVxChoiceCellEditor(changedComponent.componentProperties.cellEditorProperties, context); } break;
    }

    cellEditor.dataProvider = changedComponent.componentProperties.getProperty<String>("dataProvider");
    cellEditor.columnName = changedComponent.componentProperties.getProperty<String>("columnName");

    return cellEditor;
  }

  JVxEditor _createEditor(ChangedComponent changedComponent) {
    JVxEditor editor = new JVxEditor(Key(changedComponent.id), context);
    editor.cellEditor = _createCellEditor(changedComponent);
    editor.cellEditor.linkReference = changedComponent.cellEditor.linkReference;
    return editor;
  }

  IComponent _createDefaultComponent(ChangedComponent changedComponent) {
    JVxLabel component = new JVxLabel(Key(changedComponent.id), context);
    component.text = "Undefined Component '" + (changedComponent.className!=null?changedComponent.className:"") + "'!";
    return component;
  }

}