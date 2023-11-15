/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../model/component/fl_component_model.dart';
import '../../model/layout/alignments.dart';
import '../../util/parse_util.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../editor/text_field/fl_text_field_widget.dart';

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

    EdgeInsets textPadding = FlTextFieldWidget.TEXT_FIELD_PADDING(model.createTextStyle()).copyWith(left: 0, right: 0);

    textPadding = adjustPaddingWithStyles(textPadding);

    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: textPadding,
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

  EdgeInsets adjustPaddingWithStyles(EdgeInsets pPadding) {
    EdgeInsets padding = pPadding;

    if (model.styles.contains(FlLabelModel.NO_BOTTOM_PADDING_STYLE)) {
      padding = padding.copyWith(bottom: 0);
    } else if (model.styles.contains(FlLabelModel.HALF_BOTTOM_PADDING_STYLE)) {
      padding = padding.copyWith(bottom: padding.bottom / 2);
    }

    if (model.styles.contains(FlLabelModel.NO_TOP_PADDING_STYLE)) {
      padding = padding.copyWith(top: 0);
    } else if (model.styles.contains(FlLabelModel.HALF_TOP_PADDING_STYLE)) {
      padding = padding.copyWith(top: padding.top / 2);
    }

    return padding;
  }
}
