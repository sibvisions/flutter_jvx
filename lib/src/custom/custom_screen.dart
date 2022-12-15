/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/widgets.dart';

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
  final PreferredSizeWidget Function(BuildContext buildContext)? headerBuilder;

  /// Builder function which receives a context and the original screen, returns the custom screen
  final Widget Function(BuildContext buildContext, Widget? originalScreen)? screenBuilder;

  /// Builder function for custom footer
  final Widget Function(BuildContext buildContext)? footerBuilder;

  /// The menu item to access this screen, if this is left null, will use the
  final CustomMenuItem? menuItemModel;

  /// List with components that should be replaced in this screen
  final List<CustomComponent> replaceComponents;

  /// True if this screen is shown in online mode
  final bool showOnline;

  /// True if this screen is shown in offline mode
  final bool showOffline;

  /// If the custom screen sends open screen requests if it has replaced an online screen.
  final bool sendOpenScreenRequests;

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
    this.sendOpenScreenRequests = true,
  });
}
