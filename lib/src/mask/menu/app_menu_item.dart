import 'package:flutter_client/src/model/menu/menu_item_model.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';
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
    uiService.openScreen(menuItemModel.componentId);
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

