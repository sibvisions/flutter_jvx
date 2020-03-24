import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/ui/widgets/menu_empty_widget.dart';
import '../../model/menu_item.dart';
import '../../ui/widgets/menu_drawer_widget.dart';
import '../../ui/widgets/menu_grid_view.dart';
import '../../ui/widgets/menu_list_widget.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/uidata.dart';

class MenuPage extends StatelessWidget {
  List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;

  MenuPage({Key key, List<MenuItem> menuItems, this.listMenuItemsInDrawer})
      : this.menuItems = menuItems,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Custom Screen
    if (globals.customScreenManager != null) {
      this.menuItems = globals.customScreenManager.onMenu(this.menuItems);
    }

    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    bool drawerMenu;
    if (globals.applicationStyle != null) {
      drawerMenu = globals.applicationStyle.menuMode == 'drawer' ? true : false;
    } else {
      drawerMenu = false;
    }

    Color backgroundColor = Colors.white;

    if (globals.applicationStyle != null &&
        globals.applicationStyle.menuMode != null) {
      backgroundColor = globals.applicationStyle.menuMode == 'list'
          ? Colors.grey.shade200
          : Colors.grey.shade200;
    }

    if (globals.applicationStyle != null && globals.applicationStyle.desktopColor != null) {
      backgroundColor = globals.applicationStyle.desktopColor;
    }

    globals.items = this.menuItems;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: UIData.ui_kit_color_2,
        title: Text('Menu'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
            icon: Icon(FontAwesomeIcons.ellipsisV),
          ),
        ],
      ),
      body: getMenuWidget(),
      endDrawer: MenuDrawerWidget(
        menuItems: this.menuItems,
        listMenuItems: drawerMenu,
        groupedMenuMode: (globals.applicationStyle.menuMode == 'grid_grouped'),
        onItemSelected: (MenuItem item) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => globals.customScreenManager
                  .getScreen(item.action.componentId)
                  .getWidget()));
        }
        ,
      ),
    );
  }

  Widget getMenuWidget() {
    if (globals.applicationStyle != null) {
      if (globals.applicationStyle.menuMode == 'grid') {
        return MenuGridView(items: this.menuItems, groupedMenuMode: false);
      } else if (globals.applicationStyle.menuMode == 'list') {
        return MenuListWidget(
          menuItems: this.menuItems,
          );
      } else if (globals.applicationStyle.menuMode == 'drawer') {
        return MenuEmpty();
      } else if (globals.applicationStyle.menuMode == 'grid_grouped') {
        return MenuGridView(
          items: this.menuItems,
          groupedMenuMode: true,
          );
      }
    }

    return MenuGridView(
      items: this.menuItems,
      groupedMenuMode: true,
      );
  }
}
