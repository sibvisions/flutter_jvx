import '../../model/menu_item.dart';

class JVxMenuManager {
  List<MenuItem> _menuItems;

  JVxMenuManager(this._menuItems);

  get MenuItems {
    return _menuItems;
  }

  void addItem(MenuItem item, {bool checkUnique = true}) {
    if (this._menuItems == null) _menuItems = List<MenuItem>();

    if(!checkUnique)
      _menuItems.add(item);
    else if (!_menuItems.any((m) {
      return (m.action.componentId == item.action.componentId);
    })) {
      _menuItems.add(item);
    }
  }
}
