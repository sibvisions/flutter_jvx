import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/device_status_command.dart';

import '../../model/menu/menu_model.dart';
import '../../service/ui/i_ui_service.dart';
import 'app_menu_widget.dart';

class AppMenu extends StatelessWidget with UiServiceMixin {

  final MenuModel menuModel;
  final IUiService uiService;

  AppMenu({Key? key, required this.menuModel, required this.uiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Size screenSize = MediaQuery.of(context).size;
    uiService.sendCommand(DeviceStatusCommand(screenHeight: screenSize.height, screenWidth: screenSize.width, reason: "Menu has been opened"));

    return (Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          child: AppMenuWidget(
        menuGroups: menuModel.menuGroups,
        uiService: uiService,
      )),
    ));
  }
}
