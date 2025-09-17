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

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../../model/layout/layout_data.dart';
import '../../model/layout/layout_position.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlIconWrapper extends BaseCompWrapperWidget<FlIconModel> {
  const FlIconWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlIconWrapperState();
}

class _FlIconWrapperState extends BaseCompWrapperState<FlIconModel> {
  _FlIconWrapperState() : super();

  @override
  Widget build(BuildContext context) {
    final FlIconWidget widget = FlIconWidget(
      model: model,
      wrapper: (widget, padding) =>  wrapWithBadge(context, widget ?? ImageLoader.DEFAULT_IMAGE, padding: padding)
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    //we show the badge around the image and not around the whole area
    return wrapWidget(context, widget, false);
  }

  @override
  Size calculateSize(BuildContext context) {
    return model.image != null && model.image!.isNotEmpty ? model.originalSize : Size.zero;
  }

  @override
  LayoutData calculateConstrainedSize(LayoutPosition? calcPosition) {
    LayoutPosition constraintPos = calcPosition ?? layoutData.layoutPosition!;

    double positionWidth = constraintPos.width;
    double positionHeight = constraintPos.height;

    // Constraint by width
    layoutData.widthConstrains[positionWidth] = model.originalSize.width;
    // Constraint by height
    layoutData.heightConstrains[positionHeight] = model.originalSize.height;

    var sentData = LayoutData.from(layoutData);
    sentData.layoutPosition = constraintPos;
    return sentData;
  }
}
