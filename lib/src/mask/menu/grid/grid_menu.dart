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

import 'package:flutter/widgets.dart';

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
    required this.grouped,
    this.sticky = true,
    this.groupOnlyOnMultiple = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: grouped && (!groupOnlyOnMultiple || menuModel.menuGroups.length == 1)
          ? menuModel.menuGroups.map((e) => GridMenuGroup(menuGroupModel: e, onClick: onClick, sticky: sticky)).toList()
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
