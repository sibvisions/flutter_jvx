import 'package:flutter/material.dart';

import '../../../model/menu/menu_model.dart';
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuListGrouped({
    Key? key,
    required this.menuModel,
    required this.onClick,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: menuModel.menuGroups
          .map(
            (e) => AppMenuListGroup(menuGroupModel: e, onClick: onClick),
          )
          .toList(),
    );
  }
}
