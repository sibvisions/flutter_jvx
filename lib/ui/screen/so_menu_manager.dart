import '../../model/menu_item.dart';

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
      return (m.action.componentId == item.action.componentId);
    })) {
      _menuItems.add(item);
    }
  }
}
