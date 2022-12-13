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

import '../model/menu/menu_group_model.dart';
import '../model/menu/menu_item_model.dart';
import '../model/menu/menu_model.dart';

mixin SearchMixin<T extends StatefulWidget> on State<T> {
  late final TextEditingController menuSearchController;
  bool isMenuSearchEnabled = false;

  @override
  void initState() {
    super.initState();
    menuSearchController = TextEditingController();
    menuSearchController.addListener(() {
      updateMenuFilter();
    });
  }

  @override
  void dispose() {
    menuSearchController.dispose();
    super.dispose();
  }

  void updateMenuFilter() {
    setState(() {});
  }

  MenuModel applyMenuFilter(MenuModel menuModel, String? Function(MenuItemModel menuItem) labelFunction) {
    if (isMenuSearchEnabled) {
      final String searchValue = menuSearchController.text.trim().toLowerCase();
      List<MenuGroupModel> menuGroupModels = [...menuModel.menuGroups.map((e) => e.copy())];

      menuGroupModels.forEach((group) {
        if (!group.name.toLowerCase().startsWith(searchValue)) {
          group.items.removeWhere((item) => !(labelFunction(item)?.toLowerCase().contains(searchValue) ?? false));
        }
      });
      menuGroupModels.removeWhere((group) => group.items.isEmpty);

      menuModel = MenuModel(menuGroups: menuGroupModels);
    }
    return menuModel;
  }
}
