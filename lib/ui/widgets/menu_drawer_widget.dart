import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/api/request/logout.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/model/api/request/open_screen.dart';
import 'package:jvx_mobile_v3/ui/page/login_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/fontAwesomeChanger.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

/// the [Drawer] for the [AppBar] with dynamic [MenuItem]'s
class MenuDrawerWidget extends StatelessWidget {
  final List<MenuItem> menuItems;
  final bool listMenuItems;
  String title;

  MenuDrawerWidget(
      {Key key, @required this.menuItems, this.listMenuItems = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiBloc, Response>(
      builder: (context, state) {
        if (state.requestType == RequestType.LOGOUT && (state.error == null || !state.error) && !state.loading) {
          Future.delayed(Duration.zero, () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage())));
        }
        return Drawer(child: _buildListViewForDrawer(context, this.menuItems));
      }
    );
  }

  ListView _buildListViewForDrawer(BuildContext context, List<MenuItem> items) {
    List<Widget> tiles = new List<Widget>();

    tiles.add(_buildDrawerHeader());

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
        Logout logout = Logout(clientId: globals.clientId, requestType: RequestType.LOGOUT);

        BlocProvider.of<ApiBloc>(context).dispatch(logout);
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
                      : _iconBuilder(formatFontAwesomeText(item.image)))
              : null,
          onTap: () {
            prefix0.Action action = item.action;
                        title = action.label;

            OpenScreen openScreen = OpenScreen(
                action: action,
                clientId: globals.clientId,
                manualClose: false,
                requestType: RequestType.OPEN_SCREEN);

            BlocProvider.of<ApiBloc>(context).dispatch(openScreen);
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

    return new ListView(
      children: tiles,
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
        decoration: BoxDecoration(color: UIData.ui_kit_color_2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                globals.applicationStyle != null
                    ? Text(globals.applicationStyle.loginTitle,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: UIData.textColor,
                        ))
                    : Text(
                        globals.appName,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: UIData.textColor),
                      ),
                SizedBox(
                  height: 15,
                ),
                globals.username.isNotEmpty 
                ? Text(
                  'Angemeldet als',
                  style: TextStyle(color: UIData.textColor, fontSize: 12),
                )
                : Container(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  globals.username,
                  style: TextStyle(color: UIData.textColor, fontSize: 23),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                  child: Icon(
                    FontAwesomeIcons.userTie,
                    size: 60,
                  ),
                  radius: 55,
                ),
                Text(
                  'Version ${globals.appVersion}',
                  style: TextStyle(color: UIData.textColor),
                )
              ],
            )
          ],
        ));
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
