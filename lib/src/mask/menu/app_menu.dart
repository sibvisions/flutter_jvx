import 'package:flutter/material.dart';

import '../../model/menu/menu_model.dart';
import '../../service/ui/i_ui_service.dart';
import 'app_menu_widget.dart';

class AppMenu extends StatelessWidget {
  final MenuModel menuModel;
  final IUiService uiService;

  const AppMenu({Key? key, required this.menuModel, required this.uiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
