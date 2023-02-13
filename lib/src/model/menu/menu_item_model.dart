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

import '../../util/font_awesome_util.dart';

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
    required this.navigationName,
    required this.label,
    this.alternativeLabel,
    this.image,
    this.imageBuilder,
  });

  bool matchesScreenName(String screenName) {
    return [
          label,
          alternativeLabel,
          navigationName,
        ].contains(screenName) ||
        (screenName.isNotEmpty && screenLongName == (screenName));
  }

  static Widget getImage(
    BuildContext context, {
    required MenuItemModel pMenuItemModel,
    double? pSize,
    Color? pColor,
  }) {
    Widget icon = const FaIcon(
      FontAwesomeIcons.clone,
    );

    // Server side images
    String? imageName = pMenuItemModel.image;
    if (imageName != null) {
      icon = FontAwesomeUtil.getFontAwesomeIcon(
        pText: imageName,
      );
    }

    // Custom menu item
    if (pMenuItemModel.imageBuilder != null) {
      icon = pMenuItemModel.imageBuilder!.call(context);
    }

    return Builder(
      builder: (context) => Container(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        width: 40,
        height: 40,
        child: IconTheme(
          data: IconTheme.of(context).copyWith(
            size: pSize,
            color: pColor,
          ),
          child: icon,
        ),
      ),
    );
  }
}
