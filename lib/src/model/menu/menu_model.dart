/*
 * Copyright 2022 SIB Visions GmbH
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

import 'package:collection/collection.dart';

import 'menu_group_model.dart';
import 'menu_item_model.dart';

class MenuModel {
  final List<MenuGroupModel> menuGroups;
  final List<MenuItemModel> items;

  final Map<String, MenuItemModel> _navigationMap;
  final Map<String, MenuItemModel> _screenMap;
  final Map<String, MenuGroupModel> _menuMap;

  /// Returns the number of items in this menu
  int get count => items.length;


  // intern initialization
  const MenuModel._internal({
    required this.menuGroups,
    required this.items,
    required Map<String, MenuItemModel> navigationMap,
    required Map<String, MenuItemModel> screenMap,
    required Map<String, MenuGroupModel> menuMap,
  })  : _navigationMap = navigationMap,
        _screenMap = screenMap,
        _menuMap = menuMap;

  factory MenuModel({List<MenuGroupModel> menuGroups = const []}) {
    final allItems = menuGroups.expand((g) => g.items).toList(growable: false);

    final navMap = {for (var item in allItems) item.navigationName: item};
    final scrMap = {for (var item in allItems) item.screenLongName: item};
    final menMap = {for (var item in menuGroups) item.name: item};

    return MenuModel._internal(
      menuGroups: menuGroups,
      items: allItems,
      navigationMap: navMap,
      screenMap: scrMap,
      menuMap: menMap
    );
  }

  bool containsMenuItemWithLongName(String screenLongName) {
    return _screenMap.containsKey(screenLongName);
  }

  bool containsMenuGroup(String name) {
    return _menuMap.containsKey(name);
  }

  MenuItemModel? getMenuItemByClassName(String pClassName) {
    return items.firstWhereOrNull((item) => item.screenLongName.contains(pClassName));
  }

  MenuItemModel? getMenuItemByLongName(String screenLongName) {
    return _screenMap[screenLongName];
  }

  MenuItemModel? getMenuItemByNavigationName(String pNavName) {
    return _navigationMap[pNavName];
  }

  MenuGroupModel? getMenuGroup(String name) {
    return _menuMap[name];
  }

  /// Makes a deep copy of this object but keeps shallow copies of child objects
  MenuModel copy() {
    return MenuModel(
      menuGroups: menuGroups.map((e) => e.copy()).toList(),
    );
  }

}
