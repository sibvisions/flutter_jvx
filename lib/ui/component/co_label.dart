import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_creator.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import 'i_component.dart';
import 'component.dart';

class CoLabel extends Component implements IComponent {
  @override
  int verticalAlignment = 0;
  @override
  int horizontalAlignment = 0;
  String text = "";

  CoLabel(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoLabel.withCompContext(ComponentContext componentContext) {
    return CoLabel(componentContext.globalKey, componentContext.context);
  }

  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
  }

  static Alignment getLabelAlignment(
      int horizontalAlignment, int verticalAlignment) {
    switch (horizontalAlignment) {
      case 0:
        switch (verticalAlignment) {
          case 0:
            return Alignment.topLeft;
          case 1:
            return Alignment.centerLeft;
          case 2:
            return Alignment.bottomLeft;
        }
        return Alignment.centerLeft;
      case 1:
        switch (verticalAlignment) {
          case 0:
            return Alignment.topCenter;
          case 1:
            return Alignment.center;
          case 2:
            return Alignment.bottomCenter;
        }
        return Alignment.center;
      case 2:
        switch (verticalAlignment) {
          case 0:
            return Alignment.topRight;
          case 1:
            return Alignment.centerRight;
          case 2:
            return Alignment.bottomRight;
        }
        return Alignment.centerRight;
    }

    return Alignment.centerLeft;
  }

  double getBaseline() {
    double labelBaseline = 30;

    if (style != null && style.fontSize != null) {
      labelBaseline = style.fontSize / 2 + 21;
    }

    return labelBaseline;
  }

  @override
  Widget getWidget() {
    TextOverflow overflow;

    if (this.isMaximumSizeSet) overflow = TextOverflow.ellipsis;

    Widget child = Container(
      padding: EdgeInsets.only(top: 0.5),
      color: this.background,
      child: Align(
        alignment: getLabelAlignment(horizontalAlignment, verticalAlignment),
        child: Baseline(
            baselineType: TextBaseline.alphabetic,
            baseline: getBaseline(),
            child: text.trim().startsWith('<html>')
                ? Html(data: text)
                : Text(
                    text,
                    style: style,
                    overflow: overflow,
                  )),
      ),
    );

    if (this.isMaximumSizeSet) {
      return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: this.maximumSize.width),
          child: child);
    } else {
      return SizedBox(key: componentId, child: child);
    }
  }
}
