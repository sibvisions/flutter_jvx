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
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.zero,
        height: 50,
        color: backgroundOverride?.withOpacity(getConfigService().getOpacitySideMenu()) ??
            Theme.of(context).backgroundColor.withOpacity(getConfigService().getOpacitySideMenu()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 75,
              child: MenuItemModel.getImage(
                pContext: context,
                pMenuItemModel: menuItemModel,
                pSize: 25,
                pColor: Theme.of(context).primaryColor.withOpacity(getConfigService().getOpacitySideMenu()),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  menuItemModel.label,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.headline6?.color),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () =>
          onClick(pScreenLongName: menuItemModel.screenLongName, pUiService: getUiService(), pContext: context),
    );
  }
}
