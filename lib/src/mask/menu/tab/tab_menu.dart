import 'package:flutter/material.dart';

import '../../../model/menu/menu_group_model.dart';
import '../grid/widget/grid_menu_item.dart';
import '../menu.dart';

class TabMenu extends Menu {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const TabMenu({
    super.key,
    required super.menuModel,
    required super.onClick,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: menuModel.menuGroups.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.background,
            child: TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              tabs: menuModel.menuGroups.map((e) => Tab(text: e.name)).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: menuModel.menuGroups.map((e) => _getMenuGrid(model: e)).toList(),
        ),
      ),
    );
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
            model.items.map((e) => GridMenuItem(menuItemModel: e, onClick: onClick)).toList(),
          ),
        ),
      ],
    );
  }
}
