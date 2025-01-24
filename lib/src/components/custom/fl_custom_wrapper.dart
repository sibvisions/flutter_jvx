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
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

/// A custom wrapper is a component wrapper which wraps widgets which were added or replaced via the [AppManager].
class FlCustomWrapper<M extends FlComponentModel> extends BaseCompWrapperWidget<M> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final CustomComponent customComponent;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCustomWrapper({super.key, required super.model, required this.customComponent});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCustomWrapperState<M> createState() => FlCustomWrapperState();
}

class FlCustomWrapperState<M extends FlComponentModel> extends BaseCompWrapperState<M> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomComponent get customComponent => (widget as FlCustomWrapper).customComponent;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCustomWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    // Cant use model here, because it is not yet initialized
    // Will be initialized in initState of super
    widget.model.minimumSize = customComponent.minSize ?? widget.model.minimumSize;
    widget.model.maximumSize = customComponent.maxSize ?? widget.model.maximumSize;
    widget.model.preferredSize = customComponent.preferredSize ?? widget.model.preferredSize;

    super.initState();
  }

  @override
  void modelUpdated() {
    model.minimumSize = customComponent.minSize ?? model.minimumSize;
    model.maximumSize = customComponent.maxSize ?? model.maximumSize;
    model.preferredSize = customComponent.preferredSize ?? model.preferredSize;

    super.modelUpdated();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });
    return wrapWidget(child: customComponent.componentBuilder.call(context, model));
  }

}
