import 'package:flutter_client/src/model/menu/menu_item_model.dart';

class MenuGroupModel {
  final String name;
  final List<MenuItemModel> items;

  MenuGroupModel({
    required this.name,
    required this.items,
  });
}