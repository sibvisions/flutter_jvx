import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/list/widget/app_menu_list_item.dart';
import 'package:flutter_client/src/model/menu/menu_item_model.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:flutter_client/util/image/image_loader.dart';

import '../app_menu.dart';

class AppMenuListUngroup extends StatelessWidget {
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

  const AppMenuListUngroup({
    Key? key,
    required this.menuModel,
    required this.onClick,
    this.backgroundImageString,
    this.backgroundColor,
  }) : super(key: key);

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
      CustomScrollView(
        slivers: [
          SliverFixedExtentList(
            itemExtent: 50,
            delegate: SliverChildListDelegate.fixed(_getAllMenuItems()
                .map((e) => AppMenuListItem(
                      onClick: onClick,
                      model: e,
                      backgroundOverride: Theme.of(context).primaryColor,
                    ))
                .toList()),
          )
        ],
      ),
    ]);
  }

  /// Get all menu items from each group
  List<MenuItemModel> _getAllMenuItems() {
    List<MenuItemModel> menuItems = [];

    for (var e in menuModel.menuGroups) {
      e.items.forEach(((e) => menuItems.add(e)));
    }

    return menuItems;
  }
}
