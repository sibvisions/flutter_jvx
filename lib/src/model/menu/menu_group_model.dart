import 'menu_item_model.dart';

class MenuGroupModel {
  final String name;
  final List<MenuItemModel> items;

  MenuGroupModel({
    required this.name,
    required this.items,
  });

  ///Makes a deep copy of this object but keeps shallow copies of child objects
  copy() {
    return MenuGroupModel(name: name, items: [...items]);
  }
}
