import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/app_menu.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:flutter_client/util/image/image_loader.dart';

import 'widget/app_menu_grid_group.dart';

class AppMenuGridGrouped extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu
  final MenuModel menuModel;

  /// Callback when a button was pressed
  final ButtonCallback onClick;

  ///ImageString of Background Image if Set
  final String? backgroundImageString;

  ///Background Color if Set
  final Color? backgroundColor;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuGridGrouped({
    Key? key,
    required this.menuModel,
    required this.onClick,
    this.backgroundImageString,
    this.backgroundColor,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Container(
            child: Center(
              child: backgroundImageString != null ? ImageLoader.loadImage(backgroundImageString!) : null,
            ),
            color: backgroundColor,
          ),
        ),
        CustomScrollView(
          slivers: menuModel.menuGroups.map((e) => AppMenuGridGroup(menuGroupModel: e, onClick: onClick)).toList(),
        ),
      ],
    );
  }
}
