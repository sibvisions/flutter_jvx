import 'package:flutter_client/src/model/command/api/open_screen_command.dart';

import '../../model/menu/menu_item_model.dart';
import '../../service/ui/i_ui_service.dart';
import 'package:flutter/material.dart';

class AppMenuItem extends StatelessWidget {
  const AppMenuItem({
    Key? key,
    required this.menuItemModel,
    required this.uiService,
  }) : super(key: key);

  final IUiService uiService;
  final MenuItemModel menuItemModel;

  _onMenuItemClick() {
    OpenScreenCommand openScreenCommand = OpenScreenCommand(
        componentId: menuItemModel.componentId,
        reason: "MenuItem pressed"
    );
    uiService.sendCommand(openScreenCommand);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 182,
      child: (
          GestureDetector(
            onTap: _onMenuItemClick,
            child: Text(menuItemModel.label),
          )
      ),
    );
  }
}

