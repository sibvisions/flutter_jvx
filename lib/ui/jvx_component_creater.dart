import 'package:jvx_mobile_v3/ui/layout/jvx_form_layout.dart';

import 'editor/jvx_text_field.dart';
import 'component/jvx_button.dart';
import 'container/jvx_container.dart';
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
    } else if (component.className=="Label") {
      componentClass = new JVxLabel(Key(component.id), context);
    } else if (component.className=="Button") {
      componentClass = new JVxButton(Key(component.id), context);
    } else if (component.className=="TextField") {
      componentClass = new JVxTextField(Key(component.id), context);
      (componentClass as JVxTextField).setValue(component.componentProperties.getProperty("text"));
    }

    String layout = component.componentProperties.getProperty("layout");
    if (componentClass is JVxContainer && (layout?.isNotEmpty ?? true)) {
      JVxContainer container = componentClass;
      String layoutName = JVxLayout.getLayoutName(layout);

      if (layoutName=="BorderLayout") {
          container.layout = JVxBorderLayout.fromLayoutString(layout);
      } else if (layoutName=="FormLayout") {
          container.layout = JVxFormLayout.fromLayoutString(layout);
      }
    }

    componentClass?.updateProperties(component.componentProperties);

    return componentClass;
  }
}