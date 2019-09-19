import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'i_container.dart';
import 'jvx_container.dart';

class JVxSplitPanel extends JVxContainer implements IContainer {
  /// Constant for horizontal anchors.
  static const HORIZONTAL = 0;

  /// Constant for vertical anchors.
  static const VERTICAL = 1;

  /// Constant for relative anchors.
  static const RELATIVE = 2;

  int dividerPosition;
  int dividerAlignment;

  JVxSplitPanel(Key componentId, BuildContext context) : super(componentId, context);

  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    dividerPosition = properties.getProperty<int>("dividerPosition");
    dividerAlignment = properties.getProperty<int>("dividerAlignment", HORIZONTAL);
  }

  Widget getWidget() {
    JVxComponent firstComponent = getComponentWithContraint("FIRST_COMPONENT");
    JVxComponent secondComponent = getComponentWithContraint("SECOND_COMPONENT");
    List<Widget> widgets = new List<Widget>();

    if (firstComponent != null) {
      widgets.add(Expanded(child:firstComponent.getWidget()));
    } else {
      widgets.add(Container());
    }

    if (secondComponent != null) {
      widgets.add(Expanded(child:secondComponent.getWidget()));
    } else {
      widgets.add(Container());
    }

    if (dividerAlignment==HORIZONTAL || dividerAlignment == RELATIVE) {
      return Row(
        key: componentId, 
        children: widgets,
      );
    } else {
      return Column(
        key: componentId, 
        children: widgets,
      );
    }
  }
}