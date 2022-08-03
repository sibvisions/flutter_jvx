import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../custom/custom_menu_item.dart';
import '../../../util/font_awesome_util.dart';

class MenuItemModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the screen to open
  final String screenLongName;

  /// Icon to be displayed in the menu
  final String? image;

  /// Label text of the menu item in the menu
  final String label;

  final bool custom;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MenuItemModel({
    required this.screenLongName,
    required this.label,
    this.image,
    this.custom = false,
  });

  static Widget getImage({
    required BuildContext pContext,
    required MenuItemModel pMenuItemModel,
    required double pSize,
    required Color pColor,
  }) {
    Widget icon = FaIcon(
      FontAwesomeIcons.clone,
      size: pSize,
      color: pColor,
    );

    // Server side images
    String? imageName = pMenuItemModel.image;
    if (imageName != null) {
      icon = FontAwesomeUtil.getFontAwesomeIcon(
        pText: imageName,
        pIconSize: pSize,
        pColor: pColor,
      );
    }

    // Custom menu item
    if (pMenuItemModel is CustomMenuItem) {
      if (pMenuItemModel.faIcon != null) {
        icon = FaIcon(
          pMenuItemModel.faIcon,
          size: pSize,
          color: pColor,
        );
      } else if (pMenuItemModel.icon != null) {
        icon = pMenuItemModel.icon!;
      }
    }

    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: icon,
    );
  }
}
