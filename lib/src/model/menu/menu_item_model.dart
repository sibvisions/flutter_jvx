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

  /// Icon of the menu item
  final String? image;

  /// Label text of the menu item
  final String label;

  /// Alternative label text
  final String? alternativeLabel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const MenuItemModel({
    required this.screenLongName,
    required this.label,
    this.alternativeLabel,
    this.image,
  });

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
    if (pMenuItemModel is CustomMenuItem) {
      if (pMenuItemModel.faIcon != null) {
        icon = FaIcon(
          pMenuItemModel.faIcon,
        );
      } else if (pMenuItemModel.iconBuilder != null) {
        return pMenuItemModel.iconBuilder!.call();
      }
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
