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
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../editor/text_field/fl_text_field_widget.dart';

class FlLabelWidget<T extends FlLabelModel> extends FlStatelessWidget<T> {
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCancelCallback? onTapCancel;

  final bool dummy;

  final WidgetWrapper? wrapper;

  const FlLabelWidget({
    super.key,
    required super.model,
    this.onTap,
    this.onDoubleTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.dummy = false,
    this.wrapper
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    child = getTextWidget(model, pSelectable: onTap == null && onTapDown == null && onTapUp == null, pDummy: dummy);

    if (model.toolTipText != null) {
      child = getTooltipWidget(child);
    }

    EdgeInsets textPadding = FlTextFieldWidget.TEXT_FIELD_PADDING(model.createTextStyle()).copyWith(left: 0, right: 0);

    textPadding = adjustPaddingWithStyles(model, textPadding);

    if (wrapper != null) {
      child = wrapper!(child, textPadding);
    }

    return GestureDetector(
      onTap: onTap,
      onDoubleTap:onDoubleTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
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

  static Widget getTextWidget(FlLabelModel pModel, {TextStyle? pTextStyle, bool pSelectable = false, bool pDummy = false}) {
    Widget textWidget;

    if (!pDummy && ParseUtil.isHTML(pModel.text)) {
      textWidget = Html(data: pModel.text,
          style: {"body": Style(margin: Margins(left: Margin(0),
              top: Margin(0),
              bottom: Margin(0),
              right: Margin(0)))});
    }
    else {
      textWidget = Text(
          pModel.text.replaceAll("\n", ""),
          style: pTextStyle ?? pModel.createTextStyle(),
          textAlign: HorizontalAlignmentE.toTextAlign(pModel.horizontalAlignment));
    }

    if (!pDummy && pSelectable) {
      textWidget = SelectionArea(child: textWidget);
    }

    return textWidget;
  }

  static EdgeInsets adjustPaddingWithStyles(FlLabelModel pModel, EdgeInsets pPadding) {
    EdgeInsets padding = pPadding;

    if (pModel.styles.contains(FlLabelModel.STYLE_NO_BOTTOM_PADDING)) {
      padding = padding.copyWith(bottom: 0);
    } else if (pModel.styles.contains(FlLabelModel.STYLE_HALF_BOTTOM_PADDING)) {
      padding = padding.copyWith(bottom: padding.bottom / 2);
    }

    if (pModel.styles.contains(FlLabelModel.STYLE_NO_TOP_PADDING)) {
      padding = padding.copyWith(top: 0);
    } else if (pModel.styles.contains(FlLabelModel.STYLE_HALF_TOP_PADDING)) {
      padding = padding.copyWith(top: padding.top / 2);
    }

    return padding;
  }
}
