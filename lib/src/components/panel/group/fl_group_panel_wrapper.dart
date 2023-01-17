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

import '../../../layout/group_layout.dart';
import '../../../layout/i_layout.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/panel/fl_group_panel_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../service/config/config_controller.dart';
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

    _createGroupLayout();
    layoutAfterBuild = true;

    buildChildren(pSetStateOnChange: false);
  }

  @override
  modelUpdated() {
    _createGroupLayout();
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
    return (getPositioned(
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
    double groupHeaderHeight = (layoutData.layout as GroupLayout).groupHeaderHeight;

    EdgeInsets paddings;
    if (model.verticalAlignment == VerticalAlignment.BOTTOM) {
      paddings = EdgeInsets.only(bottom: groupHeaderHeight / 2);
    } else {
      paddings = EdgeInsets.only(top: groupHeaderHeight / 2);
    }

    double elevation = 3;
    if (model.hideBorder) {
      elevation = 0;
    }

    return getPositioned(
      child: Padding(
        padding: paddings,
        child: Material(
          borderRadius: BorderRadius.circular(3.0),
          elevation: elevation,
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

  void _createGroupLayout() {
    ILayout originalLayout = ILayout.getLayout(model.layout, model.layoutData, ConfigController().getScaling())!;
    layoutData.layout = GroupLayout(
      originalLayout: originalLayout,
      groupHeaderHeight: 0.0,
    );
    layoutData.children =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false).map((e) => e.id).toList();
  }

  @override
  void postFrameCallback(BuildContext context) {
    if (!mounted) {
      return;
    }

    GroupLayout layout = (layoutData.layout as GroupLayout);

    Size calculatedSize = calculateSize(context);

    double groupHeaderHeight = calculatedSize.height;

    if (groupHeaderHeight != layout.groupHeaderHeight) {
      layout.groupHeaderHeight = groupHeaderHeight;
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
      return layoutData.layoutPosition!.height - (layoutData.layout as GroupLayout).groupHeaderHeight;
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
