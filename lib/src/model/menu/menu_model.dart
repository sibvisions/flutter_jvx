import 'menu_group_model.dart';

class MenuModel {
  List<MenuGroupModel> menuGroups;

  MenuModel({this.menuGroups = const []});

  bool containsScreen(String pScreenLongName) {
    return menuGroups.any((group) => group.items.any((item) => item.screenLongName == pScreenLongName));
  }
}
