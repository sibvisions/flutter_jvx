import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../models/component_model.dart';
import 'co_menu_item_widget.dart';

class PopupComponentModel extends ComponentModel {
  Map<String, CoMenuItemWidget> _items = <String, CoMenuItemWidget>{};

  List<PopupMenuItem<String>> get menuItems {
    List<PopupMenuItem<String>> items = <PopupMenuItem<String>>[];
    _items?.forEach((k, i) => items.add(PopupMenuItem<String>(
          child: Text(i.componentModel.text ?? ''),
          enabled: i.componentModel.enabled,
          value: i.componentModel.name,
        )));
    return items;
  }

  PopupComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  void updateMenuItem(CoMenuItemWidget item) {
    _items.putIfAbsent(item.componentModel.componentId, () => item);
  }

  void removeMenuItem(CoMenuItemWidget item) {
    _items.remove(item.componentModel.componentId);
  }
}
