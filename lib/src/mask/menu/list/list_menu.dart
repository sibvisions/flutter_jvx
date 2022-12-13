/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';

import '../../../model/menu/menu_item_model.dart';
import '../../../model/response/device_status_response.dart';
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
    return CustomScrollView(
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
