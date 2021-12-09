import 'dart:collection';

import 'package:flutter_client/src/layout/i_layout.dart';
import 'package:flutter_client/src/model/command/layout/register_parent_command.dart';

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

  @override
  void initState() {
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
    uiService.sendCommand(registerParentCommand);


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  FlPanelWidget(children: children.values.toList());
  }
}
