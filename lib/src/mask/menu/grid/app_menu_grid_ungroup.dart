import 'package:flutter/material.dart';

import '../../../../util/image/image_loader.dart';
import '../../../model/menu/menu_item_model.dart';
import '../../../model/menu/menu_model.dart';
import '../app_menu.dart';
import 'widget/app_menu_grid_item.dart';

class AppMenuGridUnGroup extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu
  final MenuModel menuModel;

  /// Callback when a button was pressed
  final ButtonCallback onClick;

  ///ImageString of Background Image if Set
  final String? backgroundImageString;

  ///Background Color if Set
  final Color? backgroundColor;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuGridUnGroup({
    Key? key,
    required this.menuModel,
    required this.onClick,
    this.backgroundImageString,
    this.backgroundColor,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox.expand(
        child: Container(
          child: Center(
            child: backgroundImageString != null ? ImageLoader.loadImage(backgroundImageString!) : null,
          ),
          color: backgroundColor,
        ),
      ),
      CustomScrollView(slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          delegate: SliverChildListDelegate.fixed(
              _getAllMenuItems().map((e) => AppMenuGridItem(onClick: onClick, menuItemModel: e)).toList()),
        ),
      ]),
    ]);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Get all menu items from each group
  List<MenuItemModel> _getAllMenuItems() {
    List<MenuItemModel> menuItems = [];

    for (var e in menuModel.menuGroups) {
      e.items.forEach(((e) => menuItems.add(e)));
    }

    return menuItems;
  }
}
