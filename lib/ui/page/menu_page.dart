import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    bool drawerMenu;

    if (globals.applicationStyle != null) {
       drawerMenu = globals.applicationStyle.menuMode == 'drawer' ? true : false;
    } else {
      drawerMenu = false;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Menu'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            onPressed: () { _scaffoldKey.currentState.openEndDrawer(); },
            icon: Icon(FontAwesomeIcons.ellipsisV),
          ),
        ],
      ),
      body: getMenuWidget(),
      endDrawer: MenuDrawerWidget(menuItems: this.menuItems, listMenuItems: drawerMenu,),
    );
  }

  Widget getMenuWidget() {
    if (globals.applicationStyle != null) {
      if (globals.applicationStyle.menuMode == 'grid') {
        return MenuGridView(items: this.menuItems,);
      } else if (globals.applicationStyle.menuMode == 'list') {
        return MenuListWidget(menuItems: this.menuItems,);
      } else if (globals.applicationStyle.menuMode == 'drawer') {
        return Center(
          child: Text('Choose Item'),
        );
      }
    } else {
      return MenuGridView(items: this.menuItems,);
    }
    return null;
  }
}