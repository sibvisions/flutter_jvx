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

import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../layout/i_layout.dart';
import '../../../layout/scroll_layout.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../service/storage/i_storage_service.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_scroll_panel_widget.dart';

class FlScrollPanelWrapper extends BaseCompWrapperWidget<FlPanelModel> {
  const FlScrollPanelWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlScrollPanelWrapperState();
}

class _FlScrollPanelWrapperState extends BaseContWrapperState<FlPanelModel> {
  _FlScrollPanelWrapperState() : super();

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _vertictalController = ScrollController();

  @override
  void initState() {
    super.initState();

    _createLayout();

    buildChildren(pSetStateOnChange: false);
    registerParent();
  }

  @override
  modelUpdated() {
    _createLayout();

    super.modelUpdated();

    buildChildren();
    registerParent();
  }

  @override
  Widget build(BuildContext context) {
    FlScrollPanelWidget panelWidget = FlScrollPanelWidget(
      model: model,
      width: widthOfScrollPanel,
      height: heightOfScrollPanel,
      viewWidth: layoutData.layoutPosition?.width ?? widthOfScrollPanel,
      viewHeight: layoutData.layoutPosition?.height ?? heightOfScrollPanel,
      isScrollable: isScrollable,
      horizontalScrollController: _horizontalController,
      verticalScrollController: _vertictalController,
      children: children.values.toList(),
    );

    return (getPositioned(child: panelWidget));
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _vertictalController.dispose();

    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _createLayout() {
    ILayout originalLayout = ILayout.getLayout(model)!;

    layoutData.insets = EdgeInsets.all(model.hasStandardBorder ? 1 : 0);

    layoutData.layout = ScrollLayout(originalLayout);
    layoutData.children =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false).map((e) => e.id).toList();
  }

  double get widthOfScrollPanel {
    double width = ScrollLayout.widthOfScrollPanel(layoutData);

    if (layoutData.hasPosition) {
      width = max(layoutData.layoutPosition!.width, width);
    }

    return width;
  }

  double get heightOfScrollPanel {
    double height = ScrollLayout.heightOfScrollPanel(layoutData);

    // Forces the scroll panel to actually be the size.
    if (layoutData.hasPosition) {
      height = max(layoutData.layoutPosition!.height, height);
    }

    return height;
  }

  bool get isScrollable {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.width < widthOfScrollPanel ||
          layoutData.layoutPosition!.height < heightOfScrollPanel;
    }

    return true;
  }
}
