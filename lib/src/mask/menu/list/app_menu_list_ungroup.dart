import 'package:flutter/material.dart';

import '../../../../util/image/image_loader.dart';
import '../../../model/menu/menu_item_model.dart';
import '../menu.dart';
import 'widget/app_menu_list_item.dart';

class AppMenuListUngroup extends Menu {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool? decreasedDensity;
  final bool? useAlternativeLabel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuListUngroup({
    super.key,
    required super.menuModel,
    required super.onClick,
    super.backgroundImageString,
    super.backgroundColor,
    this.decreasedDensity,
    this.useAlternativeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox.expand(
        child: Container(
          color: backgroundColor,
          child: Center(
            child: backgroundImageString != null ? ImageLoader.loadImage(backgroundImageString!) : null,
          ),
        ),
      ),
      CustomScrollView(
        slivers: [
          SliverFixedExtentList(
            itemExtent: 50,
            delegate: SliverChildListDelegate.fixed(
              _getAllMenuItems()
                  .map((e) => AppMenuListItem(
                        onClick: onClick,
                        menuItemModel: e,
                        decreasedDensity: decreasedDensity,
                        useAlternativeLabel: useAlternativeLabel,
                      ))
                  .toList(),
            ),
          ),
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
