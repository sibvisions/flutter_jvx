import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../util/parse_util.dart';
import '../../model/component/label/fl_label_model.dart';
import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlLabelWidget<T extends FlLabelModel> extends FlStatelessWidget<T> {
  final VoidCallback? onPress;

  const FlLabelWidget({
    super.key,
    required super.model,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    child = getTextWidget(model, pSelectable: true);

    if (model.toolTipText != null) {
      child = getTooltipWidget(child);
    }

    double padding = kIsWeb ? 15 : 14;

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

  Tooltip getTooltipWidget(Widget pChild) {
    return Tooltip(message: model.toolTipText!, child: pChild);
  }

  static Widget getTextWidget(FlLabelModel pModel, {TextStyle? pTextStyle, bool pSelectable = false}) {
    Widget textWidget;

    if (ParseUtil.isHTML(pModel.text) && pSelectable) {
      textWidget = SelectableHtml(data: pModel.text);
    } else if (ParseUtil.isHTML(pModel.text)) {
      textWidget = Html(data: pModel.text);
    } else if (pSelectable) {
      textWidget = SelectableText(
        pModel.text,
        style: pTextStyle ?? pModel.createTextStyle(),
        textAlign: HorizontalAlignmentE.toTextAlign(pModel.horizontalAlignment),
      );
    } else {
      textWidget = Text(
        pModel.text,
        style: pTextStyle ?? pModel.createTextStyle(),
        textAlign: HorizontalAlignmentE.toTextAlign(pModel.horizontalAlignment),
      );
    }

    return textWidget;
  }
}
