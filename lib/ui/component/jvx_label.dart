import 'package:flutter/material.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/component/i_component.dart';
import '../../ui/component/jvx_component.dart';

class JVxLabel extends JVxComponent implements IComponent {
  String text = "";
  int verticalAlignment = 1;
  int horizontalAlignment = 0;

  JVxLabel(GlobalKey componentId, BuildContext context) : super(componentId, context);

  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    verticalAlignment = changedProperties.getProperty<int>(ComponentProperty.VERTICAL_ALIGNMENT, verticalAlignment);
    horizontalAlignment = changedProperties.getProperty<int>(ComponentProperty.HORIZONTAL_ALIGNMENT, horizontalAlignment);
  }

  static Alignment getLabelAlignment(int horizontalAlignment, int verticalAlignment) {
    switch(horizontalAlignment) {
      case 0:
        switch (verticalAlignment) {
          case 0: return Alignment.topLeft;
          case 1: return Alignment.centerLeft;
          case 2: return Alignment.bottomLeft;
        }
        return Alignment.centerLeft;
      case 1: 
        switch (verticalAlignment) {
          case 0: return Alignment.topCenter;
          case 1: return Alignment.center;
          case 2: return Alignment.bottomCenter;
        }
        return Alignment.center;
      case 2: 
        switch (verticalAlignment) {
          case 0: return Alignment.topRight;
          case 1: return Alignment.centerRight;
          case 2: return Alignment.bottomRight;
        }
      return Alignment.centerRight;
    }

    return Alignment.centerLeft;
  }

  double getBaseline() {
    double labelBaseline = 30;

    if (style!=null && style.fontSize!= null) {
      labelBaseline = style.fontSize/2+21;
    }

    return labelBaseline;
  }

  @override
  Widget getWidget() {
    return SizedBox(
      key: componentId,
      child: Container(
        padding: EdgeInsets.only(top: 0.5),
        color: this.background,
        child: Align(
          alignment: getLabelAlignment(horizontalAlignment, verticalAlignment),
          child:Baseline( 
            baselineType: TextBaseline.alphabetic,
            baseline: getBaseline(),
            child: Text(text,
              style: style,
            )
          ),
        ),
      )
    );
  }
}