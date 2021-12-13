import 'dart:collection';

import 'package:flutter/material.dart';
import '../../model/command/layout/register_parent_command.dart';
import '../../model/layout/layout_data.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../components_factory.dart';
import 'fl_panel_widget.dart';

class FlPanelWrapper extends StatefulWidget {
  const FlPanelWrapper({Key? key, required this.model}) : super(key: key);

  final FlPanelModel model;

  @override
  _FlPanelWrapperState createState() => _FlPanelWrapperState();
}

class _FlPanelWrapperState extends State<FlPanelWrapper> with UiServiceMixin {
  HashMap<String, Widget> children = HashMap();

  late LayoutData layoutData;
  late FlPanelModel panelModel;

  bool registered = false;

  @override
  void initState() {
    panelModel = widget.model;
    uiService.registerAsLiveComponent(
        id: panelModel.id,
        callback: ({newModel, position}) {
          if (position != null) {
            setState(() {
              layoutData.layoutPosition = position;
            });
          }

          if (newModel != null) {
            setState(() {
              panelModel = newModel as FlPanelModel;
              registered = false;
              sendRegister();
            });
          }
        });

    var models = uiService.getChildrenModels(panelModel.id);

    for (FlComponentModel componentModel in models) {
      Widget widget = ComponentsFactory.buildWidget(componentModel);
      children[componentModel.id] = widget;
    }

    layoutData = LayoutData(
        constraints: panelModel.constraints,
        id: panelModel.id,
        preferredSize: panelModel.preferredSize,
        minSize: panelModel.minimumSize,
        maxSize: panelModel.maximumSize);

    sendRegister();

    super.initState();
  }

  void sendRegister() {
    RegisterParentCommand registerParentCommand = RegisterParentCommand(
        layout: panelModel.layout!,
        layoutData: panelModel.layoutData,
        childrenIds: children.keys.toList(),
        parentId: panelModel.id,
        constraints: panelModel.constraints,
        reason: "Parent widget rendered");
    if (!registered) {
      registered = true;
      uiService.sendCommand(registerParentCommand);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: _getTopForPositioned(),
        left: _getLeftForPositioned(),
        width: _getWidthForPositioned() ?? 0,
        height: _getHeightForPositioned() ?? 0,
        child: FlPanelWidget(
            children: children.values.toList(), width: _getWidthForComponent(), height: _getHeightForComponent()));
  }

  double? _getWidthForPositioned() {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.width;
    }
  }

  double? _getHeightForPositioned() {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.height;
    }
  }

  double? _getWidthForComponent() {
    if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.width;
    } else if (layoutData.hasPreferredSize) {
      return layoutData.preferredSize!.width;
    } else if (layoutData.hasCalculatedSize) {
      return layoutData.calculatedSize!.width;
    }
  }

  double? _getHeightForComponent() {
    if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.height;
    } else if (layoutData.hasPreferredSize) {
      return layoutData.preferredSize!.height;
    } else if (layoutData.hasCalculatedSize) {
      return layoutData.calculatedSize!.height;
    }
  }

  double _getTopForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.top : 0.0;
  }

  double _getLeftForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.left : 0.0;
  }
}
