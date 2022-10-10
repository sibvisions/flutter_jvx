import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../util/parse_util.dart';
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
      child = getTextWidget(model);
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
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
    return Tooltip(message: model.toolTipText!, child: getTextWidget(model));
  }

  static Widget getTextWidget(FlLabelModel pModel, [TextStyle? pTextStyle]) {
    return ParseUtil.isHTML(pModel.text)
        ? Html(data: pModel.text)
        : Text(
            pModel.text,
            style: pTextStyle ?? pModel.createTextStyle(),
            textAlign: HorizontalAlignmentE.toTextAlign(pModel.horizontalAlignment),
          );
  }
}
