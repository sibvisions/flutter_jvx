import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/alignments.dart';
import '../../model/component/label/fl_label_model.dart';

class FlLabelWidget extends StatelessWidget {
  const FlLabelWidget({Key? key, required this.model}) : super(key: key);

  final FlLabelModel model;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (model.tooltipText != null) {
      child = getTooltipWidget();
    } else {
      child = getTextWidget();
    }

    return Container(
      child: child,
      decoration: BoxDecoration(color: model.background),
      alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
    );
  }

  Tooltip getTooltipWidget() {
    return Tooltip(message: model.tooltipText!, child: getTextWidget());
  }

  Text getTextWidget() {
    return Text(
      model.text,
      style: TextStyle(
        color: model.foreground,
        fontStyle: model.isItalic ? FontStyle.italic : FontStyle.normal,
        fontWeight: model.isBold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
    );
  }
}
