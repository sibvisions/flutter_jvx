import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_scaffold.dart';
import 'package:jvx_mobile_v3/ui/widgets/menu_drawer_widget.dart';
import 'package:jvx_mobile_v3/ui/widgets/menu_grid_view.dart';
import 'package:jvx_mobile_v3/ui/widgets/menu_list_widget.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class MenuPage extends StatelessWidget {
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;

  const MenuPage({Key key, this.menuItems, this.listMenuItemsInDrawer}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return CommonScaffold(
      appTitle: 'Menu',
      bodyData: getMenuWidget(),
      showDrawer: true,
      drawer: MenuDrawerWidget(menuItems: this.menuItems, listMenuItems: globals.applicationStyle.menuMode == 'drawer' ? true : false,),
    );
  }

  Widget getMenuWidget() {
    if (globals.applicationStyle.menuMode == 'grid') {
      return MenuGridView(items: this.menuItems,);
    } else if (globals.applicationStyle.menuMode == 'list') {
      return MenuListWidget(menuItems: this.menuItems,);
    } else if (globals.applicationStyle.menuMode == 'drawer') {
      return Center(
        child: Text('Choose Item'),
      );
    }
    return null;
  }
}