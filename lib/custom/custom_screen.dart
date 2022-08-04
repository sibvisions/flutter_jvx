import 'package:flutter/material.dart';

import 'custom_component.dart';
import 'custom_menu_item.dart';

/// Super class for Custom screens
class CustomScreen {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the screen to open
  final String screenLongName;

  /// Title displayed on the top of the screen
  final String? screenTitle;

  /// Builder function for custom header
  final PreferredSizeWidget Function(BuildContext)? headerBuilder;

  /// Builder function which receives a context and the original screen, returns the custom screen
  final Widget Function(BuildContext, Widget? screen)? screenBuilder;

  /// Builder function for custom footer
  final Widget Function(BuildContext)? footerBuilder;

  /// The menu item to access this screen, if this is left null, will use the
  final CustomMenuItem? menuItemModel;

  /// List with components that should be replaced in this screen
  final List<CustomComponent> replaceComponents;

  /// True if this screen is shown in online mode
  final bool showOnline;

  /// True if this screen is shown in offline mode
  final bool showOffline;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const CustomScreen({
    required this.screenLongName,
    this.showOnline = true,
    this.showOffline = false,
    this.screenBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.menuItemModel,
    this.screenTitle,
    this.replaceComponents = const [],
  });
}
