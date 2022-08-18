import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../model/menu/menu_group_model.dart';
import '../../app_menu.dart';
import 'app_menu_grid_header.dart';
import 'app_menu_grid_item.dart';

class AppMenuGridGroup extends StatelessWidget with ConfigServiceGetterMixin {
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

  const AppMenuGridGroup({Key? key, required this.menuGroupModel, required this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSliver(pushPinnedChildren: true, children: [
      SliverPersistentHeader(
          pinned: true,
          delegate: AppMenuGridHeader(
            headerText: getConfigService().translateText(menuGroupModel.name),
            height: 48,
          )),
      SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        delegate: SliverChildListDelegate.fixed(
          menuGroupModel.items.map((e) => AppMenuGridItem(menuItemModel: e, onClick: onClick)).toList(),
        ),
      ),
    ]);
  }
}
