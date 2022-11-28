import 'package:flutter/widgets.dart';

import '../../../../util/image/image_loader.dart';
import '../../../model/menu/menu_item_model.dart';
import '../menu.dart';
import 'widget/grid_menu_group.dart';
import 'widget/grid_menu_item.dart';

class GridMenu extends Menu {
  final bool grouped;
  final bool sticky;
  final bool groupOnlyOnMultiple;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const GridMenu({
    super.key,
    required super.menuModel,
    required super.onClick,
    super.backgroundColor,
    super.backgroundImageString,
    required this.grouped,
    this.sticky = true,
    this.groupOnlyOnMultiple = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Container(
            color: backgroundColor,
            child: Center(
              child: backgroundImageString != null ? ImageLoader.loadImage(backgroundImageString!) : null,
            ),
          ),
        ),
        CustomScrollView(
          slivers: grouped && (!groupOnlyOnMultiple || menuModel.menuGroups.length == 1)
              ? menuModel.menuGroups
                  .map((e) => GridMenuGroup(menuGroupModel: e, onClick: onClick, sticky: sticky))
                  .toList()
              : [
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                    ),
                    delegate: SliverChildListDelegate.fixed(
                      _getAllMenuItems().map((e) => GridMenuItem(onClick: onClick, menuItemModel: e)).toList(),
                    ),
                  ),
                ],
        ),
      ],
    );
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
