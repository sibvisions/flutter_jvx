import 'package:flutter/material.dart';

import 'custom_component.dart';
import 'custom_header.dart';
import 'custom_menu_item.dart';

/// Super class for Custom screens
class CustomScreen {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Title displayed on the top of the screen
  final String? screenTitle;

  /// Factory for custom header
  final CustomHeader Function(BuildContext)? headerFactory;

  /// Factory which returns the custom screen
  final Widget Function(BuildContext)? screenFactory;

  /// Factory for custom footer
  final Widget Function(BuildContext)? footerFactory;

  /// The menu item to access this screen, if this is left null, will use the
  final CustomMenuItem menuItemModel;

  /// List with components that should be replaced in this screen
  final List<CustomComponent> replaceComponents;

  /// True if this screen is independent from JVx
  final bool isOfflineScreen;

  //TODO: with server property => screen holds data automatically.

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const CustomScreen({
    this.isOfflineScreen = false,
    this.screenFactory,
    this.headerFactory,
    this.footerFactory,
    required this.menuItemModel,
    this.screenTitle,
    this.replaceComponents = const [],
  });
}
