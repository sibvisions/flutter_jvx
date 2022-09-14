import 'package:flutter/material.dart';

import '../../model/component/label/fl_label_model.dart';
import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlLabelWidget<T extends FlLabelModel> extends FlStatelessWidget<T> {
  final bool forceBorder;

  final VoidCallback? onPress;

  const FlLabelWidget({Key? key, required T model, this.forceBorder = false, this.onPress})
      : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (model.toolTipText != null) {
      child = getTooltipWidget();
    } else {
      child = getTextWidget();
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
        decoration: BoxDecoration(
          color: model.background,
          border: Border.all(
            color: Colors.black,
            width: 1,
            style: forceBorder ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
        child: child,
      ),
    );
  }

  Tooltip getTooltipWidget() {
    return Tooltip(message: model.toolTipText!, child: getTextWidget());
  }

  Text getTextWidget() {
    return Text(
      model.text,
      style: model.getTextStyle(),
      textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
    );
  }
}
