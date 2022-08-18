import 'package:flutter/material.dart';

import '../../../../mixin/config_service_mixin.dart';
import '../../../../util/image/image_loader.dart';
import '../../../model/menu/menu_group_model.dart';
import '../../../model/menu/menu_model.dart';
import '../app_menu.dart';
import '../grid/widget/app_menu_grid_item.dart';

class AppMenuTab extends StatelessWidget with ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final MenuModel menuModel;

  final ButtonCallback onClick;

  ///ImageString of Background Image if Set
  final String? backgroundImageString;

  ///Background Color if Set
  final Color? backgroundColor;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuTab({
    required this.menuModel,
    required this.onClick,
    Key? key,
    this.backgroundImageString,
    this.backgroundColor,
  }) : super(key: key);

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
            tabs: menuModel.menuGroups.map((e) => Tab(text: getConfigService().translateText(e.name))).toList(),
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
    return Stack(children: [
      SizedBox.expand(
        child: Container(
          child: Center(
            child: backgroundImageString != null ? ImageLoader.loadImage(backgroundImageString!) : null,
          ),
          color: backgroundColor,
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
              )),
        ],
      ),
    ]);
  }
}
