import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/action.dart' as prefix0;
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/api/request/logout.dart';
import '../../model/menu_item.dart';
import '../../model/api/request/open_screen.dart';
import '../../ui/page/login_page.dart';
import '../../ui/widgets/fontAwesomeChanger.dart';
import '../../utils/translations.dart';
import '../../utils/uidata.dart';
import '../../utils/globals.dart' as globals;

/// the [Drawer] for the [AppBar] with dynamic [MenuItem]'s
class MenuDrawerWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;
  final bool listMenuItems;
  final String currentTitle;

  MenuDrawerWidget(
      {Key key,
      @required this.menuItems,
      this.listMenuItems = false,
      this.currentTitle,
      this.groupedMenuMode = true})
      : super(key: key);

  @override
  _MenuDrawerWidgetState createState() => _MenuDrawerWidgetState();
}

class _MenuDrawerWidgetState extends State<MenuDrawerWidget> {
  String title;

  @override
  Widget build(BuildContext context) {
    title = widget.currentTitle;
    return BlocBuilder<ApiBloc, Response>(builder: (context, state) {
      if (state.requestType == RequestType.LOGOUT &&
          (state.error == null || !state.error) &&
          !state.loading) {
        Future.delayed(
            Duration.zero,
            () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginPage())));
      }
      return Drawer(
          child: Column(
        children: <Widget>[
          _buildDrawerHeader(),
          Expanded(
              flex: 2,
              child: _buildListViewForDrawer(context, this.widget.menuItems)),
              Container(
        color: UIData.ui_kit_color_2,
        child: Column(children: <Widget>[
          Divider(height: 1),
          ListTile(
            title: Text(Translations.of(context).text2('Settings', 'Settings'), style: TextStyle(color: UIData.textColor),),
            leading: Icon(FontAwesomeIcons.cog, color: UIData.textColor),
            onTap: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          Divider(height: 1, color: UIData.textColor),
          ListTile(
            title: Text(Translations.of(context).text2('Logout', 'Logout'), style: TextStyle(color: UIData.textColor)),
            leading: Icon(FontAwesomeIcons.signOutAlt, color: UIData.textColor),
            onTap: () {
              Logout logout =
                  Logout(clientId: globals.clientId, requestType: RequestType.LOGOUT);

              BlocProvider.of<ApiBloc>(context).dispatch(logout);
            },
          )
          ],)),
        ],
      ));
    });
  }

  MediaQuery _buildListViewForDrawer(BuildContext context, List<MenuItem> items) {
    List<Widget> tiles = <Widget>[];

    if (widget.listMenuItems) {
      String lastGroupName = "";
      for (int i=0; i<items.length;i++) {
        MenuItem item = items[i];

        if (widget.groupedMenuMode && item.group!=null && item.group.isNotEmpty && item.group!=lastGroupName) {
            ListTile groupTile = new ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          title: Text(item.group, style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ))); 
          tiles.add(groupTile);
          lastGroupName = item.group;
        }

        ListTile tile = new ListTile(
          title: Text(item.action.label),
          //subtitle: Text('Group: ' + item.group),
          leading: item.image != null
              ? new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: !item.image.startsWith('FontAwesome')
                      ? new Image.asset('${globals.dir}${item.image}')
                      : _iconBuilder(formatFontAwesomeText(item.image)))
              : new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    FontAwesomeIcons.clone,
                    size: 32,
                    color: Colors.grey[300],
                  )),
          onTap: () async {
            setState(() {
              title = item.action.label;
            });

            if (globals.customScreenManager != null && !globals.customScreenManager.getScreen(item.action.componentId).withServer()) {
              bool result = await Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => globals.customScreenManager
                  .getScreen(item.action.componentId)
                  .getWidget())).then((value) { 
                      setState(() {});
                  });
            } else {
                bool result = await Navigator.of(context).pop();
                prefix0.Action action = item.action;

                OpenScreen openScreen = OpenScreen(
                    action: action,
                    clientId: globals.clientId,
                    manualClose: false,
                    requestType: RequestType.OPEN_SCREEN);

                BlocProvider.of<ApiBloc>(context).dispatch(openScreen);
            }
          },
        );
        
        tiles.add(tile);

        if (i<(items.length-1))
          tiles.add(Divider(height: 1));
      }
    }

    Future popOldScreen(context) async {
      bool result = await Navigator.of(context).pop();
    }

    return MediaQuery.removePadding(
      context: context, 
      removeTop: true,
      child: ListView(
        children: tiles,
      )
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
                (globals.applicationStyle != null &&
                        globals.applicationStyle.loginTitle != null)
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
                        Translations.of(context)
                            .text2('Logged in as', 'Logged in as'),
                        style: TextStyle(color: UIData.textColor, fontSize: 12),
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  globals.displayName != null ? globals.displayName : globals.username,
                  style: TextStyle(color: UIData.textColor, fontSize: 23),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: globals.profileImage.isNotEmpty ? Image.memory(
                          base64Decode(globals.profileImage),
                          fit: BoxFit.cover,
                        ).image : null,
                  child: globals.profileImage.isNotEmpty
                      ? null
                      : Icon(
                          FontAwesomeIcons.userTie,
                          color: UIData.ui_kit_color_2,
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
