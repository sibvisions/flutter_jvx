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
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_dummy_widget.dart';

class FlDummyWrapper<M extends FlDummyModel> extends BaseCompWrapperWidget<M> {
  const FlDummyWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState createState() => _FlDummyWrapperState();
}

class _FlDummyWrapperState extends BaseCompWrapperState<FlDummyModel> {
  _FlDummyWrapperState() : super();

  @override
  Widget build(BuildContext context) {
    FlDummyWidget dummyWidget = FlDummyWidget(
      model: model,
      key: Key("${model.id}_Widget"),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: dummyWidget);
  }
}
