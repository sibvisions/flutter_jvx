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
import 'package:flutter/scheduler.dart';

import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../model/response/device_status_response.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../label/fl_label_widget.dart';

class FlGroupPanelHeaderWidget<T extends FlGroupPanelModel> extends FlStatelessWidget<T> {
  final Function(BuildContext) postFrameCallback;

  const FlGroupPanelHeaderWidget({
    super.key,
    required super.model,
    required this.postFrameCallback,
  });

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    Widget labelWidget = FlLabelWidget.getTextWidget(
      model,
      pSelectable: true,
    );

    if (model.isFlatStyle) {
      labelWidget = Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 5),
        child: labelWidget,
      );
    } else {
      labelWidget = Material(
        color: model.background ?? Theme.of(context).colorScheme.primary,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: labelWidget,
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: IUiService().layoutMode,
      builder: (context, value, child) {
        if (value == LayoutMode.Mini && model.horizontalAlignment == HorizontalAlignment.STRETCH) {
          return labelWidget;
        } else {
          HorizontalAlignment horizontalAlignment = model.horizontalAlignment;
          // If the alignment was not explicitly set, defaults to left.
          if (horizontalAlignment == HorizontalAlignment.STRETCH) {
            horizontalAlignment = HorizontalAlignment.LEFT;
          }

          return Container(
            alignment: FLUTTER_ALIGNMENT[horizontalAlignment.index][VerticalAlignment.CENTER.index],
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: labelWidget,
          );
        }
      },
    );
  }
}
