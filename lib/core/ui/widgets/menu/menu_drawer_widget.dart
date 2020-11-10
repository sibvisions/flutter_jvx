import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/core/models/app/screen_arguments.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../models/api/request.dart';
import '../../../models/api/request/logout.dart';
import '../../../models/api/request/open_screen.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/menu_item.dart';
import '../../../models/api/so_action.dart';
import '../../../models/app/app_state.dart';
import '../../../models/app/login_arguments.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/translation/app_localizations.dart';
import '../custom/custom_drawer_header.dart';
import '../custom/custom_icon.dart';

class MenuDrawerWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;
  final bool listMenuItems;
  final String currentTitle;
  final AppState appState;

  MenuDrawerWidget(
      {Key key,
      @required this.menuItems,
      this.listMenuItems = false,
      @required this.currentTitle,
      this.groupedMenuMode = true,
      @required this.appState})
      : super(key: key);

  @override
  _MenuDrawerWidgetState createState() => _MenuDrawerWidgetState();
}

class _MenuDrawerWidgetState extends State<MenuDrawerWidget> {
  String title;
  Uint8List decodedImage;

  @override
  void initState() {
    if (widget.appState.profileImage != null) {
      this.decodedImage = base64Decode(widget.appState.profileImage);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    title = widget.currentTitle;

    return BlocBuilder<ApiBloc, Response>(builder: (context, state) {
      if (state.request != null &&
          state.request.requestType == RequestType.LOGOUT &&
          (state.error == null || !state.hasError)) {
        Future.delayed(
            Duration.zero,
            () => Navigator.of(context).pushReplacementNamed('/login',
                arguments: LoginArguments(widget.appState.username)));
      }

      return Drawer(
          child: Column(
        children: <Widget>[
          _buildDrawerHeader(),
          Expanded(
              flex: 2,
              child: _buildListViewForDrawer(context, this.widget.menuItems)),
          Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: <Widget>[
                  Divider(height: 1),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context).text('Settings'),
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .bodyText1
                              .color),
                    ),
                    leading: FaIcon(FontAwesomeIcons.cog,
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color),
                    onTap: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                  ),
                  Divider(
                      height: 1,
                      color:
                          Theme.of(context).primaryTextTheme.bodyText1.color),
                  ListTile(
                    title: Text(AppLocalizations.of(context).text('Logout'),
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .bodyText1
                                .color)),
                    leading: FaIcon(FontAwesomeIcons.signOutAlt,
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color),
                    onTap: () {
                      Logout logout = Logout(
                          clientId: widget.appState.clientId,
                          requestType: RequestType.LOGOUT);

                      BlocProvider.of<ApiBloc>(context).add(logout);
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
        color: Colors.white,
        child: child,
      ),
      content: Container(
        child: Column(children: content),
      ),
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
          title: Text(
            item.text,
            overflow: TextOverflow.ellipsis,
          ),
          leading: item.image != null
              ? new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: CustomIcon(image: item.image, size: Size(32, 32)))
              : new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: FaIcon(
                    FontAwesomeIcons.clone,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  )),
          onTap: () async {
            setState(() {
              title = item.text;
            });

            if (widget.appState.screenManager != null &&
                !widget.appState.screenManager
                    .getScreen(item.componentId, templateName: item.text)
                    .withServer()) {
              // open screen
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(
                      builder: (_) => widget.appState.screenManager.getScreen(
                          item.componentId,
                          templateName: item.text) as Widget))
                  .then((value) {
                setState(() {});
              });

              Navigator.of(context).pop();
            } else {
              SoAction action =
                  SoAction(componentId: item.componentId, label: item.text);

              OpenScreen openScreen = OpenScreen(
                  action: action,
                  clientId: widget.appState.clientId,
                  manualClose: false,
                  requestType: RequestType.OPEN_SCREEN);

              BlocProvider.of<ApiBloc>(context).add(openScreen);
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
    String appName = widget.appState.appName;

    if (widget.appState.applicationStyle != null &&
        widget.appState.applicationStyle?.loginTitle != null) {
      appName = widget.appState.applicationStyle?.loginTitle;
    }

    //appName = "Langer Applikationsname";

    return AutoSizeText(appName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        minFontSize: 16,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryTextTheme.bodyText1.color,
        ));
  }

  Widget _getUsername() {
    String username = widget.appState.username;
    if (widget.appState.displayName != null)
      username = widget.appState.displayName;

    //username = 'Max Mustermann Junior';

    return AutoSizeText(username,
        maxLines: 2,
        overflow: TextOverflow.clip,
        style: TextStyle(
            color: Theme.of(context).primaryTextTheme.bodyText1.color,
            fontSize: 23),
        minFontSize: 18);
  }

  ImageProvider getProfileImage() {
    Image img = Image.memory(
      this.decodedImage,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );

    return img.image;
  }

  Widget _getAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage:
          widget.appState.profileImage.isNotEmpty ? getProfileImage() : null,
      child: widget.appState.profileImage.isNotEmpty
          ? null
          : FaIcon(
              FontAwesomeIcons.userTie,
              color: Theme.of(context).primaryColor,
              size: 60,
            ),
      radius: 55,
    );
  }

  Widget _buildDrawerHeader() {
    return CustomDrawerHeader(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
        drawerHeaderHeight: 151,
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
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
                          widget.appState.username.isNotEmpty
                              ? Text(
                                  AppLocalizations.of(context)
                                      .text('Logged in as'),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyText1
                                          .color,
                                      fontSize: 12),
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
