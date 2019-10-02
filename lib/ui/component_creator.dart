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
      component.layout = _createLayout(component, changedComponent);

    component?.updateProperties(changedComponent.componentProperties);

    if (component is JVxEditor) {
      component.initData();
    }

    return component;
  }



  ILayout _createLayout(IComponent component, ChangedComponent changedComponent) {

    if (changedComponent?.layout?.isNotEmpty ?? true) {
      String layoutName = _getLayoutName(changedComponent.layout);

      switch (layoutName) {
        case "BorderLayout": { return JVxBorderLayout.fromLayoutString(changedComponent.layout, changedComponent.layoutData); } break; 
        case "FormLayout": { return JVxFormLayout.fromLayoutString(changedComponent.layout, changedComponent.layoutData); } break; 
        case "FlowLayout": { return  JVxFlowLayout.fromLayoutString(changedComponent.layout, changedComponent.layoutData); } break;
      }
    }

    return null;
  }


  ICellEditor _createCellEditor(ComponentProperties properties) {
    ICellEditor cellEditor;

    String className = properties.cellEditorProperties.getProperty<String>("className");

    if (className?.isNotEmpty ?? true) {
      switch (className) {
        case "TextCellEditor":    { cellEditor = JVxTextCellEditor(properties.cellEditorProperties, context); } break;
        case "NumberCellEditor":  { cellEditor = JVxNumberCellEditor(properties.cellEditorProperties, context); } break;
        case "LinkedCellEditor":  { cellEditor = JVxLinkedCellEditor(properties.cellEditorProperties, context); } break; 
        case "DateCellEditor":    { cellEditor = JVxDateCellEditor(properties.cellEditorProperties, context); } break; 
        case "ImageViewer":       { cellEditor = JVxImageViewer(properties.cellEditorProperties, context); } break; 
        case "ChoiceCellEditor":  { cellEditor = JVxChoiceCellEditor(properties.cellEditorProperties, context); } break;
      }
    }

    cellEditor.dataProvider = properties.getProperty<String>("dataProvider");
    cellEditor.columnName = properties.getProperty<String>("columnName");

    return cellEditor;
  }

  JVxEditor _createEditor(ChangedComponent changedComponent) {
    JVxEditor editor = new JVxEditor(Key(changedComponent.id), context);
    editor.cellEditor = _createCellEditor(changedComponent.componentProperties);
    editor.cellEditor.linkReference = changedComponent.cellEditor.linkReference;
    return editor;
  }

  IComponent _createDefaultComponent(ChangedComponent changedComponent) {
    JVxLabel component = new JVxLabel(Key(changedComponent.id), context);
    component.text = "Undefined Component '" + (changedComponent.className!=null?changedComponent.className:"") + "'!";
    return component;
  }

  String _getLayoutName(String layoutString) {
    List<String> parameter = layoutString?.split(",");
    if (parameter!= null && parameter.length>0) {
      return parameter[0];
    } 

    return null;
  }
}