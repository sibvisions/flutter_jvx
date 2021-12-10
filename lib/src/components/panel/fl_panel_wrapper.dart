import 'dart:collection';

import 'package:flutter_client/src/layout/i_layout.dart';
import 'package:flutter_client/src/model/command/layout/register_parent_command.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';

import '../components_factory.dart';
import 'fl_panel_widget.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import 'package:flutter/material.dart';

class FlPanelWrapper extends StatefulWidget {
  const FlPanelWrapper({Key? key, required this.model}) : super(key: key);

  final FlPanelModel model;

  @override
  _FlPanelWrapperState createState() => _FlPanelWrapperState();
}

class _FlPanelWrapperState extends State<FlPanelWrapper> with UiServiceMixin {

  HashMap<String, Widget> children = HashMap();

  late LayoutData layoutData;

  bool registered = false;

  @override
  void initState() {

    layoutData = LayoutData(
        constraints: widget.model.constraints,
        id: widget.model.id,
        preferredSize: widget.model.preferredSize,
        minSize: widget.model.minimumSize,
        maxSize: widget.model.maximumSize);

    uiService.registerAsLiveComponent(widget.model.id, (FlPanelModel? btnModel, LayoutPosition? position) {

      if(position != null){
        setState(() {
          layoutData.layoutPosition = position;
        });
      }
    });


    HashMap<String, Widget> tempChildren = HashMap();
    var models = uiService.getChildrenModels(widget.model.id);

    for(FlComponentModel componentModel in models) {
      Widget widget = ComponentsFactory.buildWidget(componentModel);
      tempChildren[componentModel.id] = widget;
    }
    children = tempChildren;



    RegisterParentCommand registerParentCommand = RegisterParentCommand(
        layout: ILayout.getLayout(widget.model.layout, widget.model.layoutData)!,
        childrenIds: tempChildren.keys.toList(),
        parentId: widget.model.id,
        reason: "Parent widget rendered"
    );
    if(!registered){
      registered = true;
      uiService.sendCommand(registerParentCommand);
    }


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _getTopForPositioned(),
      left: _getLeftForPositioned(),
      width: _getWidthForPositioned() ?? 0,
      height: _getHeightForPositioned() ?? 0,
      child: FlPanelWidget(children: children.values.toList(), width: _getWidthForComponent(), height: _getHeightForComponent())
    );
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
