import 'package:flutter/material.dart';
import 'co_menu_item.dart';
import 'i_component.dart';
import 'component.dart';

class CoPopupMenu extends Component implements IComponent {
  Map<String, CoMenuItem> _items = new Map<String, CoMenuItem>();

  CoPopupMenu(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  List<CoMenuItem> get menuItems {
    List<CoMenuItem> items = new List<CoMenuItem>();
    _items?.forEach((k, i) => items.add(i));
    return items;
  }

  void updateMenuItem(CoMenuItem item) {
    _items.putIfAbsent(item.rawComponentId, () => item);
  }

  void removeMenuItem(CoMenuItem item) {
    _items.remove(item.componentId);
  }

  @override
  Widget getWidget() {
    return null;
  }
}
