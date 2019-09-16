import 'package:jvx_mobile_v3/ui/container/jvx_group_panel.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_split_panel.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_table.dart';
import 'package:jvx_mobile_v3/ui/jvx_cell_editor_creator.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_flow_layout.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_form_layout.dart';
import 'component/jvx_button.dart';
import 'container/jvx_container.dart';
import 'editor/jvx_editor.dart';
import 'layout/jvx_border_layout.dart';
import 'layout/jvx_layout.dart';
import '../model/changed_component.dart';
import 'component/jvx_component.dart';
import 'package:flutter/material.dart';
import 'container/jvx_panel.dart';
import 'component/jvx_label.dart';

class JVxComponentCreator {

  static JVxComponent create(ChangedComponent component, BuildContext context) {
    JVxComponent componentClass;

    if (component.className=="Panel") {
      componentClass = new JVxPanel(Key(component.id), context);
    } else if (component.className=="GroupPanel") {
      componentClass = new JVxGroupPanel(Key(component.id), context);
    } else if (component.className=="SplitPanel") {
      componentClass = new JVxSplitPanel(Key(component.id), context);
    } else if (component.className=="Label") {
      componentClass = new JVxLabel(Key(component.id), context);
    } else if (component.className=="Button") {
      componentClass = new JVxButton(Key(component.id), context);
    } else if (component.className=="Editor") {
      componentClass = new JVxEditor(Key(component.id), context);
      (componentClass as JVxEditor).cellEditor = JVxCellEditorCreator.create(component.componentProperties, context);
      (componentClass as JVxEditor).cellEditor.linkReference = component.cellEditor.linkReference;
    } else if (component.className=="Table") {
      componentClass = new JVxTable(Key(component.id), context);
    } else if (!component.destroy) {
      componentClass = new JVxLabel(Key(component.id), context);
      (componentClass as JVxLabel).text = "Undefined Component '";
    }

    String layout = component.componentProperties.getProperty("layout");
    if (componentClass is JVxContainer && (layout?.isNotEmpty ?? true)) {
      JVxContainer container = componentClass;
      String layoutName = JVxLayout.getLayoutName(layout);
      String layoutData = component.componentProperties.getProperty("layoutData");

      if (layoutName=="BorderLayout") {
        container.layout = JVxBorderLayout.fromLayoutString(layout, layoutData);
      } else if (layoutName=="FormLayout") {
        container.layout = JVxFormLayout.fromLayoutString(layout, layoutData);
      } else if (layoutName == "FlowLayout") { 
        container.layout = JVxFlowLayout.fromLayoutString(layout, layoutData);
      }
    }

    componentClass?.updateProperties(component.componentProperties);

    return componentClass;
  }
}