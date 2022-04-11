import 'package:flutter/material.dart';

import '../../model/component/label/fl_label_model.dart';
import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlLabelWidget<T extends FlLabelModel> extends FlStatelessWidget<T> {
  const FlLabelWidget({Key? key, required T model}) : super(key: key, model: model);

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
      style: model.getTextStyle(),
      textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
    );
  }
}
