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

import '../../model/component/fl_component_model.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../editor/text_field/fl_text_field_widget.dart';

class FlPanelWidget<T extends FlPanelModel> extends FlStatelessWidget<T> {
  const FlPanelWidget({
    super.key,
    required super.model,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    Color? background = model.background;

    if (model.hasDefaultEditorBackground) {
      background ??= FlTextFieldWidget.defaultBackground(context);
    }

    Widget panelWidget = DecoratedBox(
      decoration: BoxDecoration(color: background),
      child: Stack(children: children),
    );

    if (model.hasStandardBorder) {
      return wrapWithStandardBorder(panelWidget);
    }

    return panelWidget;
  }

  static Widget wrapWithStandardBorder(Widget pPanelWidget) {
    return Container(
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(JVxColors.BORDER_RADIUS - 1),
        border: Border.all(
          color: JVxColors.STANDARD_BORDER,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(JVxColors.BORDER_RADIUS),
      ),
      child: pPanelWidget,
    );
  }
}
