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
        if (!group.name.toLowerCase().contains(searchValue)) {
          group.items.removeWhere((item) => !(labelFunction(item)?.toLowerCase().contains(searchValue) ?? false));
        }
      });
      menuGroupModels.removeWhere((group) => group.items.isEmpty);

      menuModel = MenuModel(menuGroups: menuGroupModels);
    }
    return menuModel;
  }
}
