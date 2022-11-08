import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../util/parse_util.dart';
import '../../model/component/label/fl_label_model.dart';
import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlLabelWidget<T extends FlLabelModel> extends FlStatelessWidget<T> {
  final VoidCallback? onPress;

  const FlLabelWidget({Key? key, required T model, this.onPress}) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (model.toolTipText != null) {
      child = getTooltipWidget();
    } else {
      child = getTextWidget(model);
    }

    double padding = kIsWeb ? 14 : 13;

    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: EdgeInsets.fromLTRB(0, padding, 0, padding),
        decoration: BoxDecoration(
          color: model.background,
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
        ? SelectableHtml(data: pModel.text)
        : SelectableText(
            pModel.text,
            style: pTextStyle ?? pModel.createTextStyle(),
            textAlign: HorizontalAlignmentE.toTextAlign(pModel.horizontalAlignment),
          );
  }
}
