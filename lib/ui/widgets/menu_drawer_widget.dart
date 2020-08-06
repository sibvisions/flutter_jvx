import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../logic/bloc/api_bloc.dart';
import '../../model/so_action.dart' as prefix0;
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/api/request/logout.dart';
import '../../model/menu_item.dart';
import '../../model/api/request/open_screen.dart';
import '../../ui/page/login_page.dart';
import '../../utils/translations.dart';
import '../../utils/uidata.dart';
import '../../utils/globals.dart' as globals;
import '../../ui/widgets/custom_icon.dart';
import '../../ui/widgets/custom_drawer_header.dart';

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
              child: Column(
                children: <Widget>[
                  Divider(height: 1),
                  ListTile(
                    title: Text(
                      Translations.of(context).text2('Settings', 'Settings'),
                      style: TextStyle(color: UIData.textColor),
                    ),
                    leading:
                        Icon(FontAwesomeIcons.cog, color: UIData.textColor),
                    onTap: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                  ),
                  Divider(height: 1, color: UIData.textColor),
                  ListTile(
                    title: Text(
                        Translations.of(context).text2('Logout', 'Logout'),
                        style: TextStyle(color: UIData.textColor)),
                    leading: Icon(FontAwesomeIcons.signOutAlt,
                        color: UIData.textColor),
                    onTap: () {
                      Logout logout = Logout(
                          clientId: globals.clientId,
                          requestType: RequestType.LOGOUT);

                      BlocProvider.of<ApiBloc>(context).dispatch(logout);
                    },
                  )
                ],
              )),
        ],
      ));
    });
  }

  ListTile getGroupHeader(MenuItem item) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        title: Text(item.group,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            )));
  }

  StickyHeader getStickyHeaderGroup(Widget child, List<Widget> content) {
    return StickyHeader(
      header: Container(
        color:
            Colors.white.withOpacity(globals.applicationStyle.sidemenuOpacity),
        child: child,
      ),
      content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 11),
          child: Card(
            color: Colors.white
                .withOpacity(globals.applicationStyle.sidemenuOpacity),
            elevation: 2.0,
            child: Column(children: content),
          )),
    );
  }

  Widget _buildListViewForDrawer(BuildContext context, List<MenuItem> items) {
    List<Widget> tiles = <Widget>[];
    ListTile groupHeader;
    List<Widget> groupItems = <Widget>[];

    if (widget.listMenuItems) {
      String lastGroupName = "";
      for (int i = 0; i < items.length; i++) {
        MenuItem item = items[i];

        if (widget.groupedMenuMode &&
            item.group != null &&
            item.group.isNotEmpty &&
            item.group != lastGroupName) {
          if (groupHeader != null && groupItems.length > 0) {
            tiles.add(getStickyHeaderGroup(groupHeader, groupItems));
            groupHeader = null;
            groupItems = <Widget>[];
          }

          groupHeader = getGroupHeader(item);
          //tiles.add(groupTile);
          lastGroupName = item.group;
        }

        groupItems.add(ListTile(
          title: Text(item.action.label),
          leading: item.image != null
              ? new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: CustomIcon(image: item.image, size: Size(32, 32)))
              : new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    FontAwesomeIcons.clone,
                    size: 32,
                    color: Colors.grey[400],
                  )),
          onTap: () async {
            setState(() {
              title = item.action.label;
            });

            if (globals.customScreenManager != null &&
                !globals.customScreenManager
                    .getScreen(item.action.componentId,
                        templateName: item.templateName)
                    .withServer()) {
              // close drawer
              Navigator.of(context).pop();
              // open screen
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(
                      builder: (_) => globals.customScreenManager
                          .getScreen(item.action.componentId,
                              templateName: item.templateName)
                          .getWidget()))
                  .then((value) {
                setState(() {});
              });
            } else {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil(ModalRoute.withName('/Menu'));
              }
              prefix0.SoAction action = item.action;

              OpenScreen openScreen = OpenScreen(
                  action: action,
                  clientId: globals.clientId,
                  manualClose: false,
                  requestType: RequestType.OPEN_SCREEN);

              BlocProvider.of<ApiBloc>(context).dispatch(openScreen);
            }
          },
        ));

        //tiles.add(tile);

        if (i < (items.length - 1)) groupItems.add(Divider(height: 1));
      }
    }

    if (groupHeader != null && groupItems.length > 0) {
      tiles.add(getStickyHeaderGroup(groupHeader, groupItems));
      groupHeader = null;
      groupItems = <Widget>[];
    } else if (groupItems.length > 0) {
      tiles.addAll(groupItems);
    }

    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          children: tiles,
        ));
  }

  Widget _getAppName() {
    String appName = globals.appName;

    if (globals.applicationStyle != null &&
        globals.applicationStyle.loginTitle != null) {
      appName = globals.applicationStyle.loginTitle;
    }

    //appName = "Langer Applikationsname";

    return AutoSizeText(appName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        minFontSize: 16,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: UIData.textColor,
        ));
  }

  Widget _getUsername() {
    String username = globals.username;
    if (globals.displayName != null) username = globals.displayName;

    //username = 'Max Mustermann Junior';

    return AutoSizeText(username,
        maxLines: 2,
        overflow: TextOverflow.clip,
        style: TextStyle(color: UIData.textColor, fontSize: 23),
        minFontSize: 18);
  }

  Widget _getAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: globals.profileImage.isNotEmpty
          ? Image.memory(
              base64Decode(globals.profileImage),
              fit: BoxFit.cover,
            ).image
          : null,
      child: globals.profileImage.isNotEmpty
          ? null
          : Icon(
              FontAwesomeIcons.userTie,
              color: UIData.ui_kit_color_2,
              size: 60,
            ),
      radius: 55,
    );
  }

  Widget _buildDrawerHeader() {
    return CustomDrawerHeader(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
        drawerHeaderHeight: 151,
        decoration: BoxDecoration(color: UIData.ui_kit_color_2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
                width: 160,
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _getAppName(),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          globals.username.isNotEmpty
                              ? Text(
                                  Translations.of(context)
                                      .text2('Logged in as', 'Logged in as'),
                                  style: TextStyle(
                                      color: UIData.textColor, fontSize: 12),
                                )
                              : Container(),
                          _getUsername()
                        ])
                  ],
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_getAvatar()],
            )
          ],
        ));
  }
}
