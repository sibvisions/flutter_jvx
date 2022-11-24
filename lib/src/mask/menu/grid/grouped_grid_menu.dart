import 'package:flutter/widgets.dart';

import '../../../../util/image/image_loader.dart';
import '../menu.dart';
import 'widget/grid_menu_group.dart';

class GroupedGridMenu extends Menu {
  final bool sticky;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const GroupedGridMenu({
    super.key,
    required super.menuModel,
    required super.onClick,
    super.backgroundColor,
    super.backgroundImageString,
    this.sticky = true,
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
          slivers: menuModel.menuGroups
              .map((e) => GridMenuGroup(menuGroupModel: e, onClick: onClick, sticky: sticky))
              .toList(),
        ),
      ],
    );
  }
}
