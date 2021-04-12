import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/src/ui/component/model/component_model.dart';

import '../co_menu_item_widget.dart';

class PopupMenuComponentModel extends ComponentModel {
  Map<String, CoMenuItemWidget> _items = <String, CoMenuItemWidget>{};

  List<PopupMenuItem<String>> get menuItems {
    List<PopupMenuItem<String>> items = <PopupMenuItem<String>>[];
    _items.forEach((k, i) => items.add(PopupMenuItem<String>(
          child: Text(i.componentModel.text),
          enabled: i.componentModel.enabled,
          value: i.componentModel.name,
        )));
    return items;
  }

  PopupMenuComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  void updateMenuItem(CoMenuItemWidget item) {
    _items.putIfAbsent(item.componentModel.componentId, () => item);
  }

  void removeMenuItem(CoMenuItemWidget item) {
    _items.remove(item.componentModel.componentId);
  }
}
