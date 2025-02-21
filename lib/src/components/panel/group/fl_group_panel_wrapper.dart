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

import '../../../layout/i_layout.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../service/storage/i_storage_service.dart';
import '../../../util/jvx_colors.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import '../fl_sized_panel_widget.dart';
import 'fl_group_panel_header_widget.dart';

class FlGroupPanelWrapper extends BaseCompWrapperWidget<FlGroupPanelModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlGroupPanelWrapper({super.key, required super.model});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlGroupPanelWrapperState();
}

class _FlGroupPanelWrapperState extends BaseContWrapperState<FlGroupPanelModel> {
  _FlGroupPanelWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool layoutAfterBuild = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    _createLayout();
    layoutAfterBuild = true;

    buildChildren(pSetStateOnChange: false);
  }

  @override
  modelUpdated() {
    _createLayout();
    super.modelUpdated();

    layoutAfterBuild = true;

    if (!buildChildren()) {
      setState(() {});
    }
  }

  @override
  affected() {
    layoutAfterBuild = true;

    buildChildren();
  }

  @override
  Widget build(BuildContext context) {
    if (model.isFlatStyle) {
      return _buildFlat(context);
    } else {
      return _buildModern(context);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _buildFlat(BuildContext context) {
    return (wrapWidget(
      child: Column(
        verticalDirection: verticalDirection,
        children: [
          FlGroupPanelHeaderWidget(model: model, postFrameCallback: postFrameCallback),
          const Divider(
            color: JVxColors.COMPONENT_BORDER,
            height: 0.0,
            thickness: 1.0,
          ),
          FlSizedPanelWidget(
            model: model,
            width: widthOfGroupPanel,
            height: heightOfGroupPanel,
            children: children.values.toList(),
          ),
        ],
      ),
    ));
  }

  Widget _buildModern(BuildContext context) {
    double groupHeaderHeight = layoutData.insets.top;

    EdgeInsets paddings;
    if (model.verticalAlignment == VerticalAlignment.BOTTOM) {
      paddings = EdgeInsets.only(bottom: groupHeaderHeight / 2);
    } else {
      paddings = EdgeInsets.only(top: groupHeaderHeight / 2);
    }

    List<BoxShadow> shadows = [];
    if (!model.isBorderHidden) {
      shadows = [
        const BoxShadow(offset: Offset(0.0, 3.0), blurRadius: 3.0, spreadRadius: -1.0, color: Color(0x33000000)),
        const BoxShadow(offset: Offset(0.0, 3.0), blurRadius: 4.0, spreadRadius: 1.0, color: Color(0x24000000)),
        const BoxShadow(offset: Offset(0.0, 1.0), blurRadius: 8.0, spreadRadius: 1.0, color: Color(0x1F000000)),
      ];
    }

    return wrapWidget(
      child: Padding(
        padding: paddings,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: shadows,
          ),
          child: Column(
            verticalDirection: verticalDirection,
            children: [
              Container(
                height: groupHeaderHeight / 2,
                clipBehavior: Clip.none,
                child: OverflowBox(
                  maxHeight: groupHeaderHeight,
                  minHeight: groupHeaderHeight,
                  alignment: model.verticalAlignment == VerticalAlignment.BOTTOM
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  child: FlGroupPanelHeaderWidget(
                    model: model,
                    postFrameCallback: postFrameCallback,
                  ),
                ),
              ),
              FlSizedPanelWidget(
                model: model,
                width: widthOfGroupPanel,
                height: heightOfGroupPanel,
                children: children.values.toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createLayout() {
    layoutData.layout = ILayout.getLayout(model);
    layoutData.children =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false).map((e) => e.id).toList();
  }

  @override
  void postFrameCallback(BuildContext context) {
    if (!mounted) {
      return;
    }

    // This is the context of the header, not of this panel!
    double groupHeaderHeight = calculateSize(context).height;

    if (groupHeaderHeight != layoutData.insets.top) {
      layoutData.insets = EdgeInsets.only(top: groupHeaderHeight);
      layoutAfterBuild = true;
    }

    if (layoutAfterBuild) {
      layoutAfterBuild = false;
      registerParent();
    }
  }

  double get widthOfGroupPanel {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.width;
    }

    return 0.0;
  }

  double get heightOfGroupPanel {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.height - layoutData.insets.vertical;
    }

    return 0.0;
  }

  VerticalDirection get verticalDirection {
    if (model.verticalAlignment == VerticalAlignment.BOTTOM) {
      return VerticalDirection.up;
    } else {
      return VerticalDirection.down;
    }
  }
}
