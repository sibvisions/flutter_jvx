import 'dart:convert' as utf8;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/logic/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/model/api/request/logout.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/api/response/response.dart';
import 'package:jvx_flutterclient/ui/page/login_page.dart';
import 'package:jvx_flutterclient/ui/page/settings_page.dart';
import 'package:jvx_flutterclient/ui/widgets/custom_drawer_header.dart';
import 'package:jvx_flutterclient/utils/translations.dart';
import 'package:tinycolor/tinycolor.dart';
import '../utils/uidata.dart';
import '../utils/globals.dart' as globals;
import '../ui/widgets/my_popup_menu.dart' as mypopup;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

class WebFrame extends StatefulWidget {
  const WebFrame({
    Key key,
    @required this.menu,
    @required this.screen,
  }) : super(key: key);

  final Widget menu;
  final Widget screen;

  @override
  _WebFrameState createState() => _WebFrameState();
}

class _WebFrameState extends State<WebFrame> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (globals.layoutMode == 'Full') {
      return Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(child: SettingsPage()),
        body: Column(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        isVisible
                            ? Container(
                                width: 250,
                                height: double.infinity,
                                color: (globals.applicationStyle != null &&
                                        globals.applicationStyle.topMenuColor !=
                                            null)
                                    ? TinyColor(globals
                                            .applicationStyle.topMenuColor)
                                        .lighten()
                                        .color
                                    : TinyColor(Color(0xff2196f3))
                                        .lighten()
                                        .color,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: (globals.applicationStyle == null ||
                                          globals.applicationStyle
                                                  ?.topMenuLogo ==
                                              null)
                                      ? Image.asset(
                                          globals.package
                                              ? 'packages/jvx_flutterclient/assets/images/sibvisions.png'
                                              : 'assets/images/sibvisions.png',
                                          fit: BoxFit.contain)
                                      : Image.memory(
                                          utf8.base64Decode(globals.files[
                                              globals.applicationStyle
                                                  .topMenuLogo]),
                                          fit: BoxFit.contain),
                                ))
                            : Container(),
                        SizedBox(
                          width: 15,
                        ),
                        IconButton(
                          hoverColor: Colors.black,
                          icon: Icon(
                            FontAwesomeIcons.bars,
                            color: (globals.applicationStyle != null &&
                                    globals.applicationStyle.topMenuIconColor !=
                                        null)
                                ? globals.applicationStyle.topMenuIconColor
                                : Color(0xffffffff),
                            size: 26,
                          ),
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          hoverColor: Colors.black,
                          icon: Icon(
                            FontAwesomeIcons.cog,
                            color: (globals.applicationStyle != null &&
                                    globals.applicationStyle.topMenuIconColor !=
                                        null)
                                ? globals.applicationStyle.topMenuIconColor
                                : Color(0xffffffff),
                            size: 26,
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState.openEndDrawer();
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        IconButton(
                          hoverColor: Colors.black,
                          icon: Icon(
                            FontAwesomeIcons.powerOff,
                            color: (globals.applicationStyle != null &&
                                    globals.applicationStyle.topMenuIconColor !=
                                        null)
                                ? globals.applicationStyle.topMenuIconColor
                                : Color(0xffffffff),
                            size: 26,
                          ),
                          onPressed: () {
                            Logout logout = Logout(
                                clientId: globals.clientId,
                                requestType: RequestType.LOGOUT);

                            BlocProvider.of<ApiBloc>(context).dispatch(logout);
                            SystemChrome.setApplicationSwitcherDescription(
                                ApplicationSwitcherDescription(
                                    label: globals.appName));
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        _buildDrawerHeader(),
                      ],
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    color: (globals.applicationStyle != null &&
                            globals.applicationStyle.topMenuColor != null)
                        ? globals.applicationStyle.topMenuColor
                            .withOpacity(0.95)
                        : Color(0xff2196f3).withOpacity(0.95)),
              ),
            ),
            isVisible
                ? Flexible(
                    flex: 23,
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: 250,
                            color: (globals.applicationStyle != null &&
                                    globals.applicationStyle.sideMenuColor !=
                                        null)
                                ? globals.applicationStyle.sideMenuColor
                                    .withOpacity(0.95)
                                : Color(0xff171717).withOpacity(0.95),
                            child: widget.menu),
                        Expanded(
                            child: widget.screen != null
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: widget.screen,
                                  )
                                : globals.files.containsKey(
                                        globals.applicationStyle.desktopIcon)
                                    ? Container(
                                        decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: MemoryImage(utf8.base64Decode(
                                              globals.files[globals
                                                  .applicationStyle
                                                  .desktopIcon])),
                                          fit: BoxFit.cover,
                                        ),
                                      ))
                                    : Container()),
                      ],
                    ),
                  )
                : Flexible(
                    flex: 23,
                    child: widget.screen != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: widget.screen,
                          )
                        : Container(
                            decoration: globals.files.containsKey(
                                    globals.applicationStyle.desktopIcon)
                                ? BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(utf8.base64Decode(
                                          globals.files[globals
                                              .applicationStyle.desktopIcon])),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : null),
                  ),
          ],
        ),
      );
    } else {
      if (widget.screen != null) {
        return widget.screen;
      }
      return widget.menu;
    }
  }

  Widget _getAvatar() {
    String username = globals.username;
    if (globals.displayName != null) username = globals.displayName;

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: (globals.applicationStyle != null &&
                globals.applicationStyle.topMenuColor != null)
            ? globals.applicationStyle.topMenuColor.withOpacity(0.95)
            : Color(0xff2196f3).withOpacity(0.95),
      ),
      child: mypopup.PopupMenuButton<int>(
        itemBuilder: (context) => [
          mypopup.PopupMenuItem(
            enabled: false,
            value: 0,
            child: Container(
              color: (globals.applicationStyle != null &&
                      globals.applicationStyle.topMenuColor != null)
                  ? globals.applicationStyle.topMenuColor.withOpacity(0.95)
                  : Color(0xff2196f3).withOpacity(0.95),
              child: Center(
                child: Column(
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
                      Text(username, style: TextStyle(color: UIData.textColor)),
                    ]),
              ),
            ),
          ),
          mypopup.PopupMenuDivider(
            height: 10,
          ),
        ],
        icon: CircleAvatar(
          backgroundImage: globals.profileImage.isNotEmpty
              ? Image.memory(
                  base64Decode(globals.profileImage),
                  fit: BoxFit.fitHeight,
                ).image
              : null,
          child: globals.profileImage.isNotEmpty
              ? null
              : Icon(
                  FontAwesomeIcons.userTie,
                  color: (globals.applicationStyle != null &&
                          globals.applicationStyle.topMenuIconColor != null)
                      ? globals.applicationStyle.topMenuIconColor
                      : Color(0xffffffff),
                ),
          radius: 50,
        ),
        offset: Offset(0, 100),
        onSelected: (result) {},
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return BlocBuilder<ApiBloc, Response>(builder: (context, state) {
      if (state.requestType == RequestType.LOGOUT &&
          (state.error == null || !state.error) &&
          !state.loading) {
        Future.delayed(
            Duration.zero,
            () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginPage())));
      }

      return CustomDrawerHeader(
          padding: EdgeInsets.fromLTRB(0, 8.0, 25.0, 0),
          drawerHeaderHeight: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[_getAvatar()],
          ));
    });
  }
}
