import 'package:flutter/widgets.dart';

import '../../../model/menu/menu_model.dart';
import '../../../model/response/device_status_response.dart';
import '../app_menu.dart';
import 'widget/app_menu_list_group.dart';

class AppMenuListGrouped extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu
  final MenuModel menuModel;

  /// Callback when a button was pressed
  final ButtonCallback onClick;

  final LayoutMode? layoutMode;

  /// Text style for menu items
  final TextStyle? textStyle;

  /// Text color for menu header
  final Color? headerColor;

  final bool? decreasedDensity;
  final bool? useAlternativeLabel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuListGrouped({
    Key? key,
    required this.menuModel,
    required this.onClick,
    this.layoutMode,
    this.textStyle,
    this.headerColor,
    this.decreasedDensity,
    this.useAlternativeLabel,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: menuModel.menuGroups
          .map(
            (e) => AppMenuListGroup(
              menuGroupModel: e,
              onClick: onClick,
              layoutMode: layoutMode,
              textStyle: textStyle,
              headerColor: headerColor,
              decreasedDensity: decreasedDensity,
              useAlternativeLabel: useAlternativeLabel,
            ),
          )
          .toList(),
    );
  }
}
