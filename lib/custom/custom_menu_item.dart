import 'package:flutter/material.dart';

import '../src/model/menu/menu_item_model.dart';

/// Custom menu item
class CustomMenuItem extends MenuItemModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Group name under which this item should appear
  final String group;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomMenuItem({
    required this.group,
    required String screenLongName,
    required String label,
    String? image,
    Widget? icon,
  }) : super(label: label, image: image, screenLongName: screenLongName, icon: icon, custom: true);
}
