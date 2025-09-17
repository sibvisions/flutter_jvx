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
import '../../service/storage/i_storage_service.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_panel_widget.dart';

class FlPanelWrapper extends BaseCompWrapperWidget<FlPanelModel> {
  const FlPanelWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlPanelWrapperState();
}

class _FlPanelWrapperState extends BaseContWrapperState<FlPanelModel> {
  _FlPanelWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    createLayout();

    buildChildren(pSetStateOnChange: false);
    registerParent();
  }

  void createLayout() {
    layoutData.layout = ILayout.getLayout(model);
    layoutData.children =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false).map((e) => e.id).toList();
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
    if (model.isScreen && !model.exists) {
      return wrapWidget(context, Container());
    }

    FlPanelWidget panelWidget = FlPanelWidget(
      model: model,
      children: children.values.toList(),
    );

    return wrapWidget(context, panelWidget);
  }
}
