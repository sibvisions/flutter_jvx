import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../../drawer/web_menu.dart';
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
    bool selected = false;

    String key = "workScreenName";
    var pathSegments = (context.currentBeamLocation.state as BeamState).pathParameters;
    if (pathSegments.containsKey(key)) {
      selected = getUiService().getComponentByName(pComponentName: pathSegments[key]!)?.screenLongName ==
          menuItemModel.screenLongName;
    }

    return ListTile(
      selected: selected,
      visualDensity: context.findAncestorWidgetOfExactType<WebMenu>() != null
          ? const VisualDensity(horizontal: 0, vertical: -4)
          : null,
      leading: MenuItemModel.getImage(
        pContext: context,
        pMenuItemModel: menuItemModel,
      ),
      title: Text(
        menuItemModel.label,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () =>
          onClick(pScreenLongName: menuItemModel.screenLongName, pUiService: getUiService(), pContext: context),
    );
  }
}
