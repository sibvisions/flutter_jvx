import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import 'component_widget.dart';
import 'label_component_model.dart';

class CoLabelWidget extends ComponentWidget {
  final LabelComponentModel componentModel;

  CoLabelWidget({this.componentModel}) : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoLabelWidgetState();
}

class CoLabelWidgetState extends ComponentWidgetState<CoLabelWidget> {
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

    if (widget.componentModel.fontStyle != null &&
        widget.componentModel.fontStyle.fontSize != null) {
      labelBaseline = widget.componentModel.fontStyle.fontSize / 2; // + 21;
    }

    return labelBaseline;
  }

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    widget.componentModel.text = changedComponent.getProperty<String>(
        ComponentProperty.TEXT, widget.componentModel.text);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextOverflow overflow;

    if (widget.componentModel.isMaximumSizeSet)
      overflow = TextOverflow.ellipsis;

    if (widget.componentModel.text.isEmpty)
      this.updateProperties(widget.componentModel.changedComponent);

    Widget child = Container(
      padding: EdgeInsets.only(top: 0.5),
      color: widget.componentModel.background,
      child: Align(
        alignment: getLabelAlignment(horizontalAlignment, verticalAlignment),
        child: widget.componentModel.text.trim().startsWith('<html>')
            ? Html(data: widget.componentModel.text)
            : Text(
                widget.componentModel.text,
                style: widget.componentModel.fontStyle,
                overflow: overflow,
              ),
      ),
    );

    if (widget.componentModel.isMaximumSizeSet) {
      return ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: widget.componentModel.maximumSize.width),
          child: child);
    } else {
      return SizedBox(child: child);
    }
  }
}
