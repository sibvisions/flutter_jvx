import 'package:flutter/material.dart';

import '../../../model/menu/menu_item_model.dart';
import '../../../model/response/device_status_response.dart';
import '../../../util/image/image_loader.dart';
import '../menu.dart';
import 'widget/list_menu_group.dart';
import 'widget/list_menu_item.dart';

class ListMenu extends Menu {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final LayoutMode? layoutMode;

  /// Text style for menu items
  final TextStyle? textStyle;

  /// Text color for menu header
  final Color? headerColor;

  final bool? decreasedDensity;
  final bool? useAlternativeLabel;

  final bool grouped;
  final bool sticky;
  final bool groupOnlyOnMultiple;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ListMenu({
    super.key,
    required super.menuModel,
    required super.onClick,
    super.backgroundImageString,
    super.backgroundColor,
    this.layoutMode,
    this.textStyle,
    this.headerColor,
    this.decreasedDensity,
    this.useAlternativeLabel,
    required this.grouped,
    this.sticky = true,
    this.groupOnlyOnMultiple = false,
  });

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
          slivers: grouped && ((groupOnlyOnMultiple && menuModel.menuGroups.length > 1) || !groupOnlyOnMultiple)
              ? menuModel.menuGroups
                  .map((e) => ListMenuGroup(
                        menuGroupModel: e,
                        onClick: onClick,
                        sticky: sticky,
                        layoutMode: layoutMode,
                        textStyle: textStyle,
                        headerColor: headerColor,
                        decreasedDensity: decreasedDensity,
                        useAlternativeLabel: useAlternativeLabel,
                      ))
                  .toList()
              : [
                  SliverFixedExtentList(
                    itemExtent: 50,
                    delegate: SliverChildListDelegate.fixed(
                      _getAllMenuItems()
                          .map((e) => ListMenuItem(
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
      ],
    );
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
