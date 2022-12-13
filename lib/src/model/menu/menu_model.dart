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

import 'menu_group_model.dart';
import 'menu_item_model.dart';

class MenuModel {
  final List<MenuGroupModel> menuGroups;

  const MenuModel({this.menuGroups = const []});

  /// Returns the number of items in this menu
  int get count => menuGroups.expand((element) => element.items).length;

  bool containsScreen(String pScreenLongName) {
    return menuGroups.any((group) => group.items.any((item) => item.screenLongName == pScreenLongName));
  }

  MenuItemModel? getMenuItemByClassName(String pClassName) {
    return menuGroups
        .expand((element) => element.items)
        .firstWhere((element) => element.screenLongName.contains(pClassName));
  }

  /// Makes a deep copy of this object but keeps shallow copies of child objects
  MenuModel copy() {
    return MenuModel(menuGroups: [...menuGroups.map((e) => e.copy())]);
  }
}
