import 'package:flutter/material.dart';

class MenuItemModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the screen to open
  final String screenId;

  /// Icon to be displayed in the menu
  final String? image;

  /// Label text of the menu item in the menu
  final String label;

  /// Icon to be used when creating a custom menu item
  final Widget? icon;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MenuItemModel({
    required this.screenId,
    required this.label,
    this.image,
    this.icon,
  });
}
