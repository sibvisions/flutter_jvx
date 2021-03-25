import '../../../../models/api/response_objects/menu/menu_item.dart';

class SoMenuManager {
  List<MenuItem> _menuItems;

  SoMenuManager(this._menuItems);

  get menuItems {
    return _menuItems;
  }

  void addItem(MenuItem item, {bool checkUnique = true}) {
    if (!checkUnique)
      _menuItems.add(item);
    else if (!_menuItems.any((m) {
      return (m.componentId == item.componentId && m.text == item.text);
    })) {
      _menuItems.add(item);
    }
  }

  void addItemToMenu(
      {required String id,
      required String group,
      required String text,
      required String? image,
      bool checkUnique = true,
      required String templateName}) {
    MenuItem itemToAdd =
        MenuItem(componentId: id, image: image, group: group, text: text);

    addItem(itemToAdd, checkUnique: checkUnique);
  }
}
