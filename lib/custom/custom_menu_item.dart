import 'package:flutter/material.dart';

import '../src/model/menu/menu_item_model.dart';

/// Custom menu item
class CustomMenuItem extends MenuItemModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Group name under which this item should appear
  final String group;

  /// Font Awesome Icon to be used when creating a custom menu item
  final IconData? faIcon;

  /// Icon to be used when creating a custom menu item
  final Widget? icon;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomMenuItem({
    required this.group,
    required String screenLongName,
    required String label,
    this.faIcon,
    this.icon,
  }) : super(label: label, screenLongName: screenLongName, custom: true);
}
