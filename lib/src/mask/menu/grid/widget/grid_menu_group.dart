import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../model/menu/menu_group_model.dart';
import '../../menu_page.dart';
import 'grid_menu_header.dart';
import 'grid_menu_item.dart';

class GridMenuGroup extends StatelessWidget {
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

  const GridMenuGroup({Key? key, required this.menuGroupModel, required this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPersistentHeader(
            pinned: true,
            delegate: GridMenuHeader(
              headerText: FlutterJVx.translate(menuGroupModel.name),
              height: 48,
            )),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 210,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          delegate: SliverChildListDelegate.fixed(
            menuGroupModel.items.map((e) => GridMenuItem(menuItemModel: e, onClick: onClick)).toList(),
          ),
        ),
      ],
    );
  }
}