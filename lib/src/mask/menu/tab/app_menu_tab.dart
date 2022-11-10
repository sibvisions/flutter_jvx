import 'package:flutter/material.dart';

import '../../../../flutter_jvx.dart';
import '../../../../util/image/image_loader.dart';
import '../../../model/menu/menu_group_model.dart';
import '../grid/widget/app_menu_grid_item.dart';
import '../menu.dart';

class AppMenuTab extends Menu {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuTab({
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
    return DefaultTabController(
      length: menuModel.menuGroups.length,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: menuModel.menuGroups.map((e) => Tab(text: FlutterJVx.translate(e.name))).toList(),
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
    return Stack(children: [
      SizedBox.expand(
        child: Container(
          color: backgroundColor,
          child: Center(
            child: backgroundImageString != null ? ImageLoader.loadImage(backgroundImageString!) : null,
          ),
        ),
      ),
      CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            delegate: SliverChildListDelegate.fixed(
              model.items.map((e) => AppMenuGridItem(menuItemModel: e, onClick: onClick)).toList(),
            ),
          ),
        ],
      ),
    ]);
  }
}
