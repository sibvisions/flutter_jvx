import 'package:jvx_flutterclient/model/so_action.dart';

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

  void addItemToMenu(
      {String id,
      String group,
      String text,
      String image,
      bool checkUnique = true,
      String templateName}) {
    MenuItem itemToAdd = MenuItem(
        action: SoAction(componentId: id, label: text),
        image: image,
        group: group,
        templateName: templateName);

    addItem(itemToAdd, checkUnique: checkUnique);
  }
}
