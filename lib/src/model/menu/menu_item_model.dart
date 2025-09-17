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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../util/icon_util.dart';

class MenuItemModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Component ID of the screen to open.
  ///
  /// Screen long name
  ///
  /// Example:
  /// "com.sibvisions.apps.mobile.demo.screens.features.SecondWorkScreen:L1_MI_DOOPENWORKSCREEN_COM-SIB-APP-MOB-DEM-SCR-FEA-SECWORSCR"
  final String screenLongName;

  /// The class name.
  final String? className;

  /// Navigation name of the screen.
  final String navigationName;

  /// Icon of the menu item.
  final String? image;

  /// Image builder of the menu item.
  final WidgetBuilder? imageBuilder;

  /// Label text of the menu item.
  final String label;

  /// Alternative label text.
  final String? alternativeLabel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const MenuItemModel({
    required this.screenLongName,
    this.className,
    required this.navigationName,
    required this.label,
    this.alternativeLabel,
    this.image,
    this.imageBuilder,
  });

  bool matchesScreenName(String screenName) {
    return [label, alternativeLabel, navigationName, screenLongName].contains(screenName);
  }

  static Widget getImage(
    BuildContext context, {
    required MenuItemModel pMenuItemModel,
    double? pSize,
    Color? pColor,
  }) {
    Widget? icon;

    // Custom menu item
    if (pMenuItemModel.imageBuilder != null) {
      icon = pMenuItemModel.imageBuilder!.call(context);
    }

    if (icon == null) {
      // Server side images
      if (pMenuItemModel.image != null) {
        icon = IconUtil.fromString(pMenuItemModel.image)?.icon;
      }
    }

    return Builder(builder: (context) {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        foregroundColor: pColor,
        child: IconTheme(
          data: IconTheme.of(context).copyWith(
            size: pSize,
            color: pColor,
          ),
          child: icon ?? const FaIcon(FontAwesomeIcons.clone),
        ),
      );
    });
  }
}
