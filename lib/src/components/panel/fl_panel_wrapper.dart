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

import 'package:flutter/widgets.dart';

import '../../layout/i_layout.dart';
import '../../model/component/fl_component_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_panel_widget.dart';

class FlPanelWrapper extends BaseCompWrapperWidget<FlPanelModel> {
  const FlPanelWrapper({super.key, required super.model, super.offstage});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlPanelWrapperState();
}

class _FlPanelWrapperState extends BaseContWrapperState<FlPanelModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String? _layoutDefinition;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlPanelWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    createLayout(true);

    buildChildren(setStateOnChange: false);

    registerParent();
  }

  void createLayout([bool force = false]) {
    if (force || _layoutDefinition != model.layout) {
      layoutData.layout = ILayout.getLayout(model);
      _layoutDefinition = model.layout;
    }
  }

  @override
  modelUpdated() {
    createLayout();

    super.modelUpdated();

    buildChildren();

    registerParent();
  }

  @override
  Widget build(BuildContext context) {
    Widget w;

    if (widget.offstage) {
      w = Offstage();
    }
    else if (model.isScreen && !model.exists) {
      w = Container();
    }
    else {
      w = FlPanelWidget(
        model: model,
        children: childWidgets,
      );
    }

    return wrapWidget(context, w);
  }
}
