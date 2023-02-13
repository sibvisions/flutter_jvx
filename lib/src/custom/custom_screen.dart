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

import 'package:flutter/material.dart';

import '../../flutter_jvx.dart';
import '../model/request/api_open_screen_request.dart';
import '../model/response/menu_view_response.dart';

/// Builder function for custom header.
typedef HeaderBuilder = PreferredSizeWidget Function(BuildContext buildContext);

/// Builder function which receives a context and the original screen, returns the custom screen.
typedef ScreenBuilder = Widget Function(BuildContext buildContext, Widget? originalScreen);

/// Builder function for custom footer.
typedef FooterBuilder = Widget Function(BuildContext buildContext);

/// A component that allows to implement custom screens.
///
/// This screens are able to either replace existing JVx screens
/// (while in online and/or offline mode, see [showOnline] and [showOffline])
/// or adding new ones.
///
/// See also:
/// * [AppManager.registerScreen]
class CustomScreen {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Unique ID used to identify and possibly replace a screen.
  ///
  /// To replace a screen, use the fully qualified screen name as key.
  ///
  /// Possible values:
  /// * [MenuEntryResponse.componentId]
  /// * [MenuEntryResponse.navigationName]
  final String key;

  /// Title displayed in the [AppBar] when this screen is active.
  final String? screenTitle;

  /// Used to conveniently provide a custom header for this screen.
  final HeaderBuilder? headerBuilder;

  /// Used to wrap or replace the original screen (if applicable).
  final ScreenBuilder? screenBuilder;

  /// Used to conveniently provide a custom footer for this screen.
  final FooterBuilder? footerBuilder;

  /// Custom components that will replace original components in this screen.
  final List<CustomComponent> replaceComponents;

  /// Whether this screen is shown in online mode.
  final bool showOnline;

  /// Whether this screen is shown in offline mode.
  final bool showOffline;

  /// Whether this screen should send open screen requests when it has replaced an online screen.
  final bool sendOpenScreenRequests;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a custom screen.
  ///
  /// {@template screen.key_notice}
  /// If this screen aims to replace another screen
  /// (by using an existing screen identifier as [key]),
  /// it first tries to use the navigation name from the original screen.
  /// Otherwise [key] is used as the navigation name.
  /// {@endtemplate}
  const CustomScreen({
    required this.key,
    required this.screenTitle,
    this.screenBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.replaceComponents = const [],
    this.showOnline = true,
    this.showOffline = true,
    this.sendOpenScreenRequests = false,
  });

  /// Creates an online-only custom screen.
  ///
  /// This screen will not show up in the offline menu and can send
  /// an [ApiOpenScreenRequest] (controlled by [sendOpenScreenRequests]).
  ///
  /// {@macro screen.key_notice}
  const CustomScreen.online({
    required this.key,
    this.screenTitle,
    this.screenBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.replaceComponents = const [],
    this.sendOpenScreenRequests = true,
  })  : showOnline = true,
        showOffline = false;

  /// Creates an offline-only custom screen.
  ///
  /// This screen will not show up in the online menu and will never send an [ApiOpenScreenRequest].
  ///
  /// {@macro screen.key_notice}
  const CustomScreen.offline({
    required this.key,
    required this.screenTitle,
    this.screenBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.replaceComponents = const [],
  })  : showOnline = false,
        showOffline = true,
        sendOpenScreenRequests = false;

  /// Returns a beautified version of the key.
  get keyNavigationName {
    String navigationName = IStorageService().convertLongScreenToClassName(key);

    int end = navigationName.lastIndexOf(".");
    if (end >= 0) {
      navigationName = navigationName.substring(end + 1);
    }
    if (navigationName.endsWith("WorkScreen")) {
      navigationName = navigationName.substring(0, navigationName.length - 10);
    }

    return navigationName;
  }
}
