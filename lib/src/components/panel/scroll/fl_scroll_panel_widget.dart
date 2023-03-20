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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../model/component/fl_component_model.dart';
import '../../../util/jvx_colors.dart';
import '../fl_panel_widget.dart';

class FlScrollPanelWidget extends FlPanelWidget<FlPanelModel> {
  final ScrollController horizontalScrollController;

  final ScrollController verticalScrollController;

  const FlScrollPanelWidget({
    super.key,
    required super.model,
    required super.children,
    required this.isScrollable,
    required this.width,
    required this.height,
    required this.viewWidth,
    required this.viewHeight,
    required this.horizontalScrollController,
    required this.verticalScrollController,
  });

  final bool isScrollable;
  final double width;
  final double height;
  final double viewWidth;
  final double viewHeight;

  @override
  Widget build(BuildContext context) {
    Widget panelWidget;
    if (isScrollable) {
      Widget child = Stack(
        children: [
          IgnorePointer(
            ignoring: true,
            child: SizedBox(
              width: (width),
              height: (height),
            ),
          ),
          ...children,
        ],
      );

      if (kIsWeb) {
        panelWidget = Scrollbar(
          thumbVisibility: true,
          controller: horizontalScrollController,
          child: Scrollbar(
            controller: verticalScrollController,
            notificationPredicate: (notification) => notification.depth == 1,
            child: SizedBox(
              width: viewWidth,
              height: viewHeight,
              child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: verticalScrollController,
                  child: child,
                ),
              ),
            ),
          ),
        );
      } else {
        panelWidget = InteractiveViewer(
          constrained: false,
          child: child,
        );
      }
    } else {
      panelWidget = Stack(
        children: children,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: model.hasStandardBorder
            ? Border.all(
                color: JVxColors.COMPONENT_DISABLED_LIGHTER,
              )
            : null,
        color: model.background,
      ),
      child: panelWidget,
    );
  }
}
