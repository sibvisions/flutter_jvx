import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/menu/menu_item.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../flutterclient.dart';

class NavigationBarWidget extends StatefulWidget {
  final Widget child;
  final AppState appState;
  final Function onLogoutPressed;
  final Function(MenuItem) onMenuItemPressed;
  final List<MenuItem> menuItems;

  const NavigationBarWidget(
      {Key? key,
      required this.child,
      required this.appState,
      required this.onLogoutPressed,
      required this.onMenuItemPressed,
      required this.menuItems})
      : super(key: key);

  @override
  _NavigationBarWidgetState createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Uint8List? _decodedImg;
  bool isShowingMenu = true;

  Widget _getMenuWidget(BuildContext context) {
    return MenuListViewWidget(
        menuItems: widget.menuItems,
        groupedMenuMode: true,
        onPressed: widget.onMenuItemPressed,
        appState: widget.appState);
    if (widget.appState.applicationStyle?.menuMode != null) {
      switch (widget.appState.applicationStyle!.menuMode) {
        case 'grid':
          return MenuGridViewWidget(
              items: widget.menuItems,
              groupedMenuMode: false,
              onPressed: widget.onMenuItemPressed,
              appState: widget.appState);
        case 'grid_grouped':
          return MenuGridViewWidget(
              items: widget.menuItems,
              groupedMenuMode: true,
              onPressed: widget.onMenuItemPressed,
              appState: widget.appState);
        case 'list':
          return MenuListViewWidget(
              menuItems: widget.menuItems,
              groupedMenuMode: false,
              onPressed: widget.onMenuItemPressed,
              appState: widget.appState);
        case 'list_grouped':
          return MenuListViewWidget(
              menuItems: widget.menuItems,
              groupedMenuMode: true,
              onPressed: widget.onMenuItemPressed,
              appState: widget.appState);
        default:
          return MenuGridViewWidget(
              items: widget.menuItems,
              groupedMenuMode: false,
              onPressed: widget.onMenuItemPressed,
              appState: widget.appState);
      }
    } else {
      return Container();
    }
  }

  ImageProvider? _getImageProvider() {
    if (widget.appState.userData?.profileImage != null &&
        widget.appState.userData!.profileImage.isNotEmpty) {
      return MemoryImage(_decodedImg!);
    }

    return null;
  }

  Widget _getNavWidget() {
    return Flexible(
        flex: 2,
        child: Container(
            child: Column(
          children: [
            Image.asset(
              widget.appState.appConfig!.package
                  ? 'packages/flutterclient/assets/images/logo.jpg'
                  : 'assets/images/logo.jpg',
              height: 60,
            ),
            _getMenuWidget(context),
          ],
        )));
  }

  @override
  void initState() {
    super.initState();

    if (widget.appState.userData?.profileImage != null &&
        widget.appState.userData!.profileImage.isNotEmpty) {
      _decodedImg = base64Decode(widget.appState.userData!.profileImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: SettingsPage(
          canPop: false,
        ),
      ),
      body: Row(
        children: [
          AnimatedContainer(
              duration: const Duration(seconds: 1),
              child: isShowingMenu ? _getNavWidget() : Container()),
          Flexible(
            flex: 8,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  color: Theme.of(context).primaryColor,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: FaIcon(FontAwesomeIcons.ellipsisV),
                            onPressed: () {
                              setState(() {
                                isShowingMenu = !isShowingMenu;
                              });
                            }),
                        Row(
                          children: [
                            IconButton(
                                icon: FaIcon(FontAwesomeIcons.signOutAlt),
                                color:
                                    Theme.of(context).primaryColor.textColor(),
                                onPressed: () {
                                  widget.onLogoutPressed();
                                }),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton(
                                icon: FaIcon(FontAwesomeIcons.cog),
                                color:
                                    Theme.of(context).primaryColor.textColor(),
                                onPressed: () {
                                  scaffoldKey.currentState?.openEndDrawer();
                                }),
                            SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              backgroundImage: _getImageProvider(),
                              child: widget.appState.userData?.profileImage ==
                                          null ||
                                      widget.appState.userData!.profileImage
                                          .isEmpty
                                  ? FaIcon(
                                      FontAwesomeIcons.userTie,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .textColor(),
                                      size: 40,
                                    )
                                  : Container(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(child: widget.child)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
