import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../model/menu/menu_group_model.dart';
import '../../app_menu.dart';
import '../../grid/widget/app_menu_grid_header.dart';
import 'app_menu_list_item.dart';

class AppMenuListGroup extends StatelessWidget {
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

  const AppMenuListGroup({
    Key? key,
    required this.onClick,
    required this.menuGroupModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> listGroupItems = [];

    for (int i = 0; i < menuGroupModel.items.length; i++) {
      listGroupItems.add(AppMenuListItem(menuItemModel: menuGroupModel.items.elementAt(i), onClick: onClick));

      // Enable this if to remove the last divider
      //if (i < (menuGroupModel.items.length - 1)) {
      listGroupItems.add(const Divider(
        color: Colors.grey,
        height: 0.0,
        thickness: 0.5,
      ));
      //}
    }

    return MultiSliver(pushPinnedChildren: true, children: [
      SliverPersistentHeader(
        pinned: true,
        delegate: AppMenuGridHeader(
          headerText: menuGroupModel.name,
          height: kIsWeb ? 48 : 50,
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate.fixed(
          listGroupItems,
        ),
      ),
    ]);
  }
}
