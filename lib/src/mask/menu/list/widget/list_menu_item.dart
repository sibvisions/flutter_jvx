import 'package:flutter/material.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../model/component/panel/fl_panel_model.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../menu_page.dart';

class ListMenuItem extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu item
  final MenuItemModel menuItemModel;

  /// Callback to be called when button is pressed
  final ButtonCallback onClick;

  /// Text style for inner widgets
  final TextStyle? textStyle;

  final bool decreasedDensity;
  final bool useAlternativeLabel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ListMenuItem({
    super.key,
    required this.menuItemModel,
    required this.onClick,
    this.textStyle,
    bool? decreasedDensity,
    bool? useAlternativeLabel,
  })  : decreasedDensity = decreasedDensity ?? false,
        useAlternativeLabel = useAlternativeLabel ?? false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    bool selected = false;

    String key = "workScreenName";
    var pathSegments = (context.currentBeamLocation.state as BeamState).pathParameters;
    if (pathSegments.containsKey(key)) {
      String screenName = pathSegments[key]!;
      selected = menuItemModel.screenLongName.contains(
          (IStorageService().getComponentByName(pComponentName: screenName) as FlPanelModel?)!.screenClassName!);
    }

    var leading = MenuItemModel.getImage(
      context,
      pMenuItemModel: menuItemModel,
    );

    onTap() => onClick(context, pScreenLongName: menuItemModel.screenLongName);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 50) {
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
          visualDensity:
              decreasedDensity ? const VisualDensity(horizontal: 0, vertical: VisualDensity.minimumDensity) : null,
          leading: leading,
          title: Text(
            (useAlternativeLabel ? menuItemModel.alternativeLabel : null) ?? menuItemModel.label,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
          onTap: onTap,
        );
      },
    );
  }
}
