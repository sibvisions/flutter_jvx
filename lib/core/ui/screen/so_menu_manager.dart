import '../../models/api/response/menu_item.dart';

class SoMenuManager {
  List<MenuItem> _menuItems;

  SoMenuManager(this._menuItems);

  get menuItems {
    return _menuItems;
  }

  void addItem(MenuItem item, {bool checkUnique = true}) {
    if (this._menuItems == null) _menuItems = List<MenuItem>();

    if (!checkUnique)
      _menuItems.add(item);
    else if (!_menuItems.any((m) {
      return (m.componentId == item.componentId && m.text == item.text);
    })) {
      _menuItems.add(item);
    }
  }

  void addItemToMenu(
      {String id,
      String group,
      String text,
      String image,
      bool checkUnique = true,
      String templateName}) {
    MenuItem itemToAdd = MenuItem(
        componentId: id,
        image: image,
        group: group,
        text: templateName);

    addItem(itemToAdd, checkUnique: checkUnique);
  }
}
