import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jvx_flutterclient/core/ui/layout/i_alignment_constants.dart';

import 'component_widget.dart';
import 'models/label_component_model.dart';

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
      widget.componentModel
          .updateProperties(context, widget.componentModel.changedComponent);

    Widget child = Container(
      padding: EdgeInsets.only(top: 0.5),
      color: widget.componentModel.background,
      child: Row(
        mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
            widget.componentModel.horizontalAlignment),
        crossAxisAlignment: IAlignmentConstants.getCrossAxisAlignment(
            widget.componentModel.verticalAlignment),
        children: <Widget>[
          Baseline(
            baselineType: TextBaseline.alphabetic,
            baseline: widget.componentModel.getBaseline(),
            child: widget.componentModel.text.trim().startsWith('<html>')
                ? Html(data: widget.componentModel.text)
                : Text(
                    widget.componentModel.text,
                    style: widget.componentModel.fontStyle,
                    overflow: overflow,
                  ),
          )
        ],
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
