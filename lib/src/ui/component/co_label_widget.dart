import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'component_widget.dart';
import 'model/label_component_model.dart';

class CoLabelWidget extends ComponentWidget {
  final LabelComponentModel componentModel;

  CoLabelWidget({required this.componentModel})
      : super(componentModel: componentModel);

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

  Widget _getText() {
    if (widget.componentModel.text.trim().startsWith('<html>')) {
      return Html(data: widget.componentModel.text);
    }

    TextOverflow? overflow;

    if (widget.componentModel.isMaximumSizeSet)
      overflow = TextOverflow.ellipsis;

    return Text(
      widget.componentModel.text,
      style: widget.componentModel.fontStyle,
      overflow: overflow,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      padding: EdgeInsets.only(top: 0.5),
      color: widget.componentModel.background,
      child: Align(
        alignment: getLabelAlignment(widget.componentModel.horizontalAlignment,
            widget.componentModel.verticalAlignment),
        child: Baseline(
            baselineType: TextBaseline.alphabetic,
            baseline: widget.componentModel.getBaseline(),
            child: _getText()),
      ),
    );

    if (widget.componentModel.isMaximumSizeSet) {
      return ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: widget.componentModel.maximumSize!.width),
          child: child);
    } else {
      return SizedBox(child: child);
    }
  }
}
