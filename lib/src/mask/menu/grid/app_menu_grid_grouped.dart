import 'package:flutter/widgets.dart';

import '../../../../util/image/image_loader.dart';
import '../menu.dart';
import 'widget/app_menu_grid_group.dart';

class AppMenuGridGrouped extends Menu {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuGridGrouped({
    super.key,
    required super.menuModel,
    required super.onClick,
    super.backgroundColor,
    super.backgroundImageString,
  });

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
