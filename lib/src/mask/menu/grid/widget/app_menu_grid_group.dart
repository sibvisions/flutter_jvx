import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/app_menu.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../model/menu/menu_group_model.dart';
import '../../../../service/ui/i_ui_service.dart';
import 'app_menu_grid_header.dart';
import 'app_menu_grid_item.dart';

class AppMenuGridGroup extends StatelessWidget {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Callback for menu items
  final ButtonCallback onClick;
  /// Model of this group
  final MenuGroupModel menuGroupModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  const AppMenuGridGroup({
        Key? key,
        required this.menuGroupModel,
        required this.onClick
      }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return MultiSliver(pushPinnedChildren: true, children: [
      SliverPersistentHeader(
          pinned: true,
          delegate:
              AppMenuGridHeader(headerText: menuGroupModel.name, height: 50)),
      SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        delegate: SliverChildListDelegate.fixed(
          menuGroupModel.items
              .map((e) => AppMenuGridItem(menuItemModel: e, onClick: onClick))
              .toList(),
        ),
      ),
    ]);
  }
}
