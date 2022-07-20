import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/menu/menu_item_model.dart';

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
    required String screenId,
    required String label,
    String? image,
    Widget? icon,
  }) : super(label: label, image: image, screenId: screenId, icon: icon, custom: true);
}
