import 'package:flutter/material.dart';

/// Custom menu item
class CustomMenuItem {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Group name under which this item should appear
  final String group;

  /// Label of the item
  final String label;

  /// Widget used as icon of the item
  final Widget? icon;

  /// In case of an offline screen -> arbitrary name
  /// In case of an replace screen -> The screenId of the normal button
  final String screenId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomMenuItem({
    required this.group,
    required this.label,
    required this.screenId,
    this.icon,
  });
}
