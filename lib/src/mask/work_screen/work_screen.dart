import 'dart:developer';


import 'package:flutter_client/src/layout/i_layout.dart';
import 'package:flutter_client/src/model/command/layout/preferred_size_command.dart';
import 'package:flutter_client/src/model/command/layout/register_parent_command.dart';
import 'package:flutter_client/src/model/command/layout/set_size_command.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';

import '../../mixin/command_service_mixin.dart';
import '../../model/command/api/device_status_command.dart';

import '../../components/components_factory.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import 'package:flutter/material.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({Key? key, required this.screen}) : super(key: key);

  final FlComponentModel screen;

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> with CommandServiceMixin {


  Widget screen = const Text("dummy");

  @override
  void initState() {
    screen = ComponentsFactory.buildWidget(widget.screen);
    super.initState();
  }

  _getScreenSize(double height, double width) {
    DeviceStatusCommand deviceStatusCommand = DeviceStatusCommand(
        screenWidth: width,
        screenHeight: height,
        reason: "Screen has been opened"
    );
    commandService.sendCommand(deviceStatusCommand);

    SetSizeCommand setSizeCommand = SetSizeCommand(
        componentId: widget.screen.id,
        size: Size(width, height),
        reason: "Work Screen Screen Size"
    );
    commandService.sendCommand(setSizeCommand);



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text((widget.screen as FlPanelModel).screenClassName!)),
      body: Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
            _getScreenSize(constraints.maxHeight, constraints.maxWidth);
            return Stack(children: [screen],);
          }
        ),
      )
    );
  }
}
