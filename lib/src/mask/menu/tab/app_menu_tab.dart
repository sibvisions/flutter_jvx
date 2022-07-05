import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/app_menu.dart';
import 'package:flutter_client/src/mask/menu/grid/widget/app_menu_grid_item.dart';
import 'package:flutter_client/src/model/menu/menu_group_model.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';

class AppMenuTab extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final MenuModel menuModel;

  final ButtonCallback onClick;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuTab({required this.menuModel, required this.onClick, Key? key}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: menuModel.menuGroups.length,
        child: Scaffold(
          appBar: TabBar(
            tabs: menuModel.menuGroups.map((e) => Tab(text: e.name)).toList(),
          ),
          body: TabBarView(
            children: menuModel.menuGroups.map((e) => _getMenuGrid(model: e)).toList(),
          ),
        ));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _getMenuGrid({required MenuGroupModel model}) {
    return CustomScrollView(
      slivers: [
        SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            delegate: SliverChildListDelegate.fixed(
              model.items.map((e) => AppMenuGridItem(menuItemModel: e, onClick: onClick)).toList(),
            )),
      ],
    );
  }
}
