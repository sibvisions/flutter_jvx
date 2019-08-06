import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_scaffold.dart';
import 'package:jvx_mobile_v3/ui/widgets/menu_drawer_widget.dart';
import 'package:jvx_mobile_v3/ui/widgets/menu_grid_view.dart';
import 'package:jvx_mobile_v3/ui/widgets/menu_list_widget.dart';

class MenuPage extends StatelessWidget {
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;

  const MenuPage({Key key, this.menuItems, this.listMenuItemsInDrawer}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return CommonScaffold(
      appTitle: 'Menu',
      bodyData: /*this.listMenuItemsInDrawer ? Center(child: Text('Choose Menu Item'),) : */ MenuGridView(items: this.menuItems),
      showDrawer: true,
      drawer: MenuDrawerWidget(menuItems: this.menuItems, listMenuItems: this.listMenuItemsInDrawer,),
    );
  }
}