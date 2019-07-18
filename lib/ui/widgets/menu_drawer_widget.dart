import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class MenuDrawerWidget extends StatelessWidget {
  final List<MenuItem> menuItems;
  final bool listMenuItems;

  MenuDrawerWidget({Key key, @required this.menuItems, this.listMenuItems = false}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _buildListViewForDrawer(context, this.menuItems)
    );
  }

  ListView _buildListViewForDrawer(BuildContext context, List<MenuItem> items) {
    List<Widget> tiles = new List<Widget>();

    tiles.add(
      DrawerHeader(
        child: Text(globals.appName, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
        decoration: BoxDecoration(
          color: UIData.ui_kit_color_2
        ),
      )
    );

    ListTile settingsTile = new ListTile(
      title: Text(Translations.of(context).text('settings')),
      leading: Icon(FontAwesomeIcons.cog),
      onTap: () {},
    );

    ListTile logoutTile = new ListTile(
      title: Text(Translations.of(context).text('logout')),
      leading: Icon(FontAwesomeIcons.signOutAlt),
      onTap: () {},
    );
    if (listMenuItems) {
      for (MenuItem item in items) {
        ListTile tile = new ListTile(
          title: Text(item.action.label),
          subtitle: Text('Group: ' + item.group),
          onTap: () {
            print("Pressed Menu Item: " + item.action.label);
          },
        );

        tiles.add(tile);
      }
    }

    tiles.add(Divider());
    tiles.add(settingsTile);
    tiles.add(Divider());
    tiles.add(logoutTile);

    return new ListView(children: tiles,);
  }
}