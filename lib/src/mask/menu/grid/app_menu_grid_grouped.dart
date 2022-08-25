import 'package:flutter/widgets.dart';

import '../../../../util/image/image_loader.dart';
import '../../../model/menu/menu_model.dart';
import '../app_menu.dart';
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
            color: backgroundColor,
            child: Center(
              child: backgroundImageString != null ? ImageLoader.loadImage(backgroundImageString!) : null,
            ),
          ),
        ),
        CustomScrollView(
          slivers: menuModel.menuGroups.map((e) => AppMenuGridGroup(menuGroupModel: e, onClick: onClick)).toList(),
        ),
      ],
    );
  }
}
