import 'dart:convert' as utf8;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/logic/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/model/api/request/logout.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/api/response/response.dart';
import 'package:jvx_flutterclient/ui/page/login_page.dart';
import 'package:jvx_flutterclient/ui/page/settings_page.dart';
import 'package:jvx_flutterclient/ui/widgets/custom_drawer_header.dart';
import 'package:jvx_flutterclient/utils/translations.dart';
import '../utils/uidata.dart';
import '../utils/globals.dart' as globals;
import '../ui/widgets/my_popup_menu.dart' as mypopup;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';

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
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(child: SettingsPage()),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                          width: 250,
                          child: (globals.applicationStyle == null ||
                                  globals.applicationStyle?.loginLogo == null)
                              ? Image.asset(
                                  globals.package
                                      ? 'packages/jvx_flutterclient/assets/images/sibvisions.png'
                                      : 'assets/images/sibvisions.png',
                                  fit: BoxFit.fitHeight)
                              : Image.memory(
                                  utf8.base64Decode(globals.files[
                                      globals.applicationStyle.loginLogo]),
                                  fit: BoxFit.fitHeight)),
                      SizedBox(
                        width: 15,
                      ),
                      IconButton(
                        hoverColor: Colors.black,
                        icon: Icon(
                          FontAwesomeIcons.bars,
                          color: Colors.white,
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
                  _buildDrawerHeader(),
                ],
              ),
              decoration: BoxDecoration(
                color: UIData.ui_kit_color_2.withOpacity(0.95),
              ),
            ),
          ),
          isVisible
              ? Flexible(
                  flex: 12,
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: 250,
                          color: UIData.ui_kit_color_2.withOpacity(0.95),
                          child: widget.menu),
                      Expanded(
                          child: widget.screen != null
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: widget.screen,
                                )
                              : Container()),
                    ],
                  ),
                )
              : Flexible(
                  flex: 12,
                  child: widget.screen != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget.screen,
                        )
                      : Container(),
                ),
        ],
      ),
    );
  }

  Widget _getAvatar() {
    String username = globals.username;
    if (globals.displayName != null) username = globals.displayName;

    return mypopup.PopupMenuButton<int>(
      itemBuilder: (context) => [
        mypopup.PopupMenuItem(
          enabled: false,
          value: 0,
          child: Container(
            color: UIData.ui_kit_color_2,
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
        mypopup.PopupMenuItem(
          value: 1,
          child: Center(
            child: Text(
              Translations.of(context).text2('Logout', 'Logout'),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        mypopup.PopupMenuItem(
          value: 2,
          child: Center(
            child: Text(
              Translations.of(context).text2('Settings', 'Settings'),
              style: TextStyle(color: Colors.black),
            ),
          ),
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
                color: UIData.ui_kit_color_2,
                size: 60,
              ),
        radius: 50,
      ),
      offset: Offset(0, 100),
      onSelected: (result) {
        if (result == 2) {
          _scaffoldKey.currentState.openEndDrawer();
        } else if (result == 1) {
          Logout logout = Logout(
              clientId: globals.clientId, requestType: RequestType.LOGOUT);

          BlocProvider.of<ApiBloc>(context).dispatch(logout);
        }
      },
    );
  }

  Widget _getAppName() {
    String appName = globals.appName;

    if (globals.applicationStyle != null &&
        globals.applicationStyle.loginTitle != null) {
      appName = globals.applicationStyle.loginTitle;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: AutoSizeText(appName != null ? appName : '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          minFontSize: 16,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: UIData.textColor,
          )),
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
          // decoration: BoxDecoration(color: UIData.ui_kit_color_2.withOpacity(0.95)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[_getAvatar()],
          ));
    });
  }
}
