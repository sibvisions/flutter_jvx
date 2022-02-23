import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/device_status_command.dart';

import '../../model/menu/menu_model.dart';
import 'app_menu_group.dart';

class AppMenu extends StatelessWidget with UiServiceMixin {
  final MenuModel menuModel;

  AppMenu({Key? key, required this.menuModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    uiService.sendCommand(DeviceStatusCommand(
        screenHeight: screenSize.height,
        screenWidth: screenSize.width,
        reason: "Menu has been opened"));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: menuModel.menuGroups
              .map((e) => AppMenuGroup(menuGroupModel: e, uiService: uiService))
              .toList(),
        ),
      )
    );
  }
}


// menuModel.menuGroups
//     .map((e) => AppMenuGroup(menuGroupModel: e, uiService: uiService))
// .toList()
