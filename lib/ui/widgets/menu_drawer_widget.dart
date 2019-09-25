import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/logic/bloc/logout_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/open_screen_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/logout_view_model.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/open_screen_view_model.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/page/settings_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/ui/widgets/fontAwesomeChanger.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

/// the [Drawer] for the [AppBar] with dynamic [MenuItem]s
class MenuDrawerWidget extends StatelessWidget {
  LogoutBloc logoutBloc = new LogoutBloc();
  StreamSubscription<FetchProcess> apiStreamSubscription;
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
      UserAccountsDrawerHeader(
        decoration: BoxDecoration(
          color: UIData.ui_kit_color_2
        ),
        accountEmail: globals.applicationStyle != null ? Text(globals.appName) : null,
        accountName: globals.applicationStyle != null ? Text(globals.applicationStyle.loginTitle, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),) : Text(globals.appName),
      )
    );

    ListTile settingsTile = new ListTile(
      title: Text(Translations.of(context).text2('Settings', 'Settings')),
      leading: Icon(FontAwesomeIcons.cog),
      onTap: () {
        Navigator.of(context).pushNamed('/settings');
      },
    );

    ListTile logoutTile = new ListTile(
      title: Text(Translations.of(context).text2('Logout', 'Logout')),
      leading: Icon(FontAwesomeIcons.signOutAlt),
      onTap: () {
        apiStreamSubscription = apiSubscription(logoutBloc.apiResult, context);
        logoutBloc.logoutSink.add(new LogoutViewModel(clientId: globals.clientId));
      },
    );

    if (listMenuItems) {
      for (MenuItem item in items) {
        ListTile tile = new ListTile(
          title: Text(item.action.label),
          subtitle: Text('Group: ' + item.group),
          leading: item.image != null 
                    ? new CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: !item.image.startsWith('FontAwesome') 
                              ? new Image.asset('${globals.dir}${item.image}')
                              : _iconBuilder(formatFontAwesomeText(item.image))
                    )
                    : null,
          onTap: () {
            prefix0.Action action = item.action;
            OpenScreenBloc openScreenBloc = OpenScreenBloc();
            StreamSubscription<FetchProcess> apiStreamSubscription;

            apiStreamSubscription = apiSubscription(openScreenBloc.apiResult, context);
            openScreenBloc.openScreenSink.add(
              new OpenScreenViewModel(action: action, clientId: globals.clientId, manualClose: true)
            );
          },
        );

        tiles.add(tile);
      }
    }

    if (this.listMenuItems) tiles.add(Divider());
    tiles.add(settingsTile);
    tiles.add(Divider());
    tiles.add(logoutTile);
    // tiles.add(Divider());

    return new ListView(children: tiles,);
  }

  Icon _iconBuilder(Map data) {
    Icon icon = new Icon(
      data['icon'],
      size: double.parse(data['size']),
      color: UIData.ui_kit_color_2,
      key: data['key'],
      textDirection: data['textDirection'],
    );

    return icon;
  }
}