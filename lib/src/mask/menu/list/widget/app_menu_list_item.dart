import 'package:flutter/material.dart';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../app_menu.dart';

class AppMenuListItem extends StatelessWidget with ConfigServiceGetterMixin, UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu item
  final MenuItemModel menuItemModel;

  /// Callback to be called when button is pressed
  final ButtonCallback onClick;

  /// Background override color.
  final Color? backgroundOverride;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppMenuListItem({
    Key? key,
    required this.menuItemModel,
    required this.onClick,
    this.backgroundOverride,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: MenuItemModel.getImage(
        pContext: context,
        pMenuItemModel: menuItemModel,
        pSize: 32,
        pColor: Theme.of(context).primaryColor,
      ),
      title: Text(
        menuItemModel.label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade800),
      ),
      onTap: () =>
          onClick(pScreenLongName: menuItemModel.screenLongName, pUiService: getUiService(), pContext: context),
    );
  }
}
