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

import '../../model/component/fl_component_model.dart';
import '../../model/component/label/fl_label_model.dart';
import '../../util/parse_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_label_widget.dart';

class FlLabelWrapper extends BaseCompWrapperWidget<FlLabelModel> {
  const FlLabelWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlLabelWrapperState();
}

class _FlLabelWrapperState extends BaseCompWrapperState<FlLabelModel> {
  _FlLabelWrapperState() : super();

  @override
  Widget build(BuildContext context) {
    final FlLabelWidget widget = FlLabelWidget(model: model);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  Size calculateSize(BuildContext context) {
    if (ParseUtil.isHTML(model.text)) {
      return const Size(400, 100);
    }
    double minWidth = (context.findRenderObject() as RenderBox).getMaxIntrinsicWidth(double.infinity).ceilToDouble();
    double minHeight = (context.findRenderObject() as RenderBox).getMaxIntrinsicHeight(double.infinity).ceilToDouble();
    return Size(minWidth, minHeight);
  }
}
