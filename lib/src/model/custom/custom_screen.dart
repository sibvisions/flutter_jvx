import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/custom/custom_component.dart';

import 'custom_header.dart';
import 'custom_menu_item.dart';

/// Super class for Custom screens
class CustomScreen {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the screen - used for identification
  final String screenName;

  /// Title displayed on the top of the screen
  final String? screenTitle;

  /// Factory which returns the custom screen
  final Widget Function()? screenFactory;

  /// Factory for custom footer
  final Widget Function()? footerFactory;

  /// Factory for custom header
  final CustomHeader Function()? headerFactory;

  /// The menu item to access this screen, if this is left null, will use the
  final CustomMenuItem? menuItemModel;

  /// List with components that should be replaced in this screen
  final List<CustomComponent> replaceComponents;

  /// True if this screen is independent from JVx
  final bool isOfflineScreen;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const CustomScreen({
    required this.screenName,
    this.isOfflineScreen = false,
    this.screenFactory,
    this.headerFactory,
    this.footerFactory,
    this.menuItemModel,
    this.screenTitle,
    this.replaceComponents = const [],
  });
}
