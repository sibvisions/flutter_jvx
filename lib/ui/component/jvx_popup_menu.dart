import 'package:flutter/material.dart';
import '../../ui/component/jvx_menu_item.dart';
import '../../ui/component/i_component.dart';
import '../../ui/component/jvx_component.dart';

class JVxPopupMenu extends JVxComponent implements IComponent {
  Map<String, JVxMenuItem> _items = new Map<String, JVxMenuItem>();

  JVxPopupMenu(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  List<JVxMenuItem> get menuItems {
    List<JVxMenuItem> items = new List<JVxMenuItem>();
    _items?.forEach((k, i) => items.add(i));
    return items;
  }

  void updateMenuItem(JVxMenuItem item) {
    _items.putIfAbsent(item.rawComponentId, () => item);
  } 

  void removeMenuItem(JVxMenuItem item) {
    _items.remove(item.componentId);
  }


  @override
  Widget getWidget() {
    return null;
  }
}
