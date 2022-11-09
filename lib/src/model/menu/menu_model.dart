import 'menu_group_model.dart';
import 'menu_item_model.dart';

class MenuModel {
  List<MenuGroupModel> menuGroups;

  MenuModel({this.menuGroups = const []});

  get count => menuGroups.expand((element) => element.items).length;

  bool containsScreen(String pScreenLongName) {
    return menuGroups.any((group) => group.items.any((item) => item.screenLongName == pScreenLongName));
  }

  MenuItemModel? getMenuItemByClassName(String pClassName) {
    return menuGroups
        .expand((element) => element.items)
        .firstWhere((element) => element.screenLongName.contains(pClassName));
  }
}
