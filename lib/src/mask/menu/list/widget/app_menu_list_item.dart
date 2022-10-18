import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../../../services.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../../../model/response/device_status_response.dart';
import '../../../drawer/web_menu.dart';
import '../../app_menu.dart';

class AppMenuListItem extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu item
  final MenuItemModel menuItemModel;

  /// Callback to be called when button is pressed
  final ButtonCallback onClick;

  /// Background override color.
  final Color? backgroundOverride;

  final LayoutMode? layoutMode;

  /// Text style for inner widgets
  final TextStyle? textStyle;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuListItem({
    Key? key,
    required this.menuItemModel,
    required this.onClick,
    this.backgroundOverride,
    this.layoutMode,
    this.textStyle,
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
      selected = IUiService().getComponentByName(pComponentName: pathSegments[key]!)?.screenLongName ==
          menuItemModel.screenLongName;
    }

    var leading = MenuItemModel.getImage(
      pContext: context,
      pMenuItemModel: menuItemModel,
    );

    onTap() => onClick(pScreenLongName: menuItemModel.screenLongName, pUiService: IUiService(), pContext: context);

    bool isInWebMenu = WebMenu.maybeOf(context) != null;

    if (isInWebMenu && layoutMode == LayoutMode.Small) {
      var tileThemeData = ListTileTheme.of(context);
      return Material(
        color: selected ? tileThemeData.selectedTileColor : tileThemeData.tileColor,
        child: InkWell(
          onTap: onTap,
          child: IconTheme.merge(
            data: IconThemeData(color: selected ? tileThemeData.selectedColor : tileThemeData.iconColor),
            child: leading,
          ),
        ),
      );
    }

    return ListTile(
      selected: selected,
      visualDensity: isInWebMenu ? const VisualDensity(horizontal: 0, vertical: VisualDensity.minimumDensity) : null,
      leading: leading,
      title: Text(
        menuItemModel.label,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      ),
      onTap: onTap,
    );
  }
}
