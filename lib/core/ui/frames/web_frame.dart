import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinycolor/tinycolor.dart';

import '../../../injection_container.dart';
import '../../models/api/request.dart';
import '../../models/api/request/logout.dart';
import '../../models/api/response.dart';
import '../../models/app/app_state.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/translation/app_localizations.dart';
import '../pages/login_page.dart';
import '../pages/settings_page.dart';
import '../widgets/custom/custom_drawer_header.dart';
import '../widgets/util/app_state_provider.dart';
import '../widgets/util/shared_pref_provider.dart';
import '../widgets/web/web_menu_list_widget.dart';
import '../widgets/custom/popup_menu.dart' as mypopup;

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

  AppState appState;

  bool isVisible = true;
  Image profileImg;

  bool get hasMultipleGroups {
    int groupCount = 0;
    String lastGroup = "";
    if (this.appState.items != null) {
      this.appState.items?.forEach((m) {
        if (m.group != lastGroup) {
          groupCount++;
          lastGroup = m.group;
        }
      });
    }
    return (groupCount > 1);
  }

  @override
  void initState() {
    this.appState = sl<AppState>();

    if (this.appState.profileImage != null &&
        this.appState.profileImage.isNotEmpty) {
      profileImg = Image.memory(base64Decode(this.appState.profileImage));
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    this.appState.appFrame.setMenu(WebMenuListWidget(
        appState: this.appState,
        menuItems: this.appState.items,
        groupedMenuMode: hasMultipleGroups));
    if (this.appState.layoutMode == 'Full') {
      return Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
            child: SettingsPage(
          appState: this.appState,
          manager: SharedPrefProvider.of(context).manager,
        )),
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
                                color:
                                    (this.appState.applicationStyle != null &&
                                            this
                                                    .appState
                                                    .applicationStyle
                                                    .topMenuColor !=
                                                null)
                                        ? TinyColor(this
                                                .appState
                                                .applicationStyle
                                                .topMenuColor)
                                            .lighten()
                                            .color
                                        : TinyColor(Color(0xff2196f3))
                                            .lighten()
                                            .color,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: (appState.applicationStyle == null ||
                                          this
                                                  .appState
                                                  .applicationStyle
                                                  ?.topMenuLogo ==
                                              null)
                                      ? Image.asset(
                                          'assets/images/sibvisions.png',
                                          fit: BoxFit.contain)
                                      : Image.memory(
                                          base64Decode(this.appState.files[this
                                              .appState
                                              .applicationStyle
                                              ?.topMenuLogo]),
                                          fit: BoxFit.contain),
                                ))
                            : Container(),
                        SizedBox(
                          width: 15,
                        ),
                        Material(
                          shape: CircleBorder(),
                          color: Colors.blue,
                          child: IconButton(
                            hoverColor: Colors.black.withOpacity(0.3),
                            icon: FaIcon(
                              FontAwesomeIcons.bars,
                              color: (appState.applicationStyle != null &&
                                      this
                                              .appState
                                              .applicationStyle
                                              .topMenuIconColor !=
                                          null)
                                  ? this
                                      .appState
                                      .applicationStyle
                                      .topMenuIconColor
                                  : Color(0xffffffff),
                              size: 26,
                            ),
                            onPressed: () {
                              setState(() {
                                isVisible = !isVisible;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Material(
                          shape: CircleBorder(),
                          color: Colors.blue,
                          child: IconButton(
                            hoverColor: Colors.black.withOpacity(0.3),
                            icon: FaIcon(
                              FontAwesomeIcons.cog,
                              color: (appState.applicationStyle != null &&
                                      this
                                              .appState
                                              .applicationStyle
                                              .topMenuIconColor !=
                                          null)
                                  ? this
                                      .appState
                                      .applicationStyle
                                      .topMenuIconColor
                                  : Color(0xffffffff),
                              size: 26,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState.openEndDrawer();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Material(
                          shape: CircleBorder(),
                          color: Colors.blue,
                          child: IconButton(
                            hoverColor: Colors.black.withOpacity(0.3),
                            icon: FaIcon(
                              FontAwesomeIcons.powerOff,
                              color: (appState.applicationStyle != null &&
                                      this
                                              .appState
                                              .applicationStyle
                                              .topMenuIconColor !=
                                          null)
                                  ? this
                                      .appState
                                      .applicationStyle
                                      .topMenuIconColor
                                  : Color(0xffffffff),
                              size: 26,
                            ),
                            onPressed: () {
                              Logout logout = Logout(
                                  clientId: this.appState.clientId,
                                  requestType: RequestType.LOGOUT);

                              BlocProvider.of<ApiBloc>(context).add(logout);
                              SystemChrome.setApplicationSwitcherDescription(
                                  ApplicationSwitcherDescription(
                                      label: this.appState.appName));
                            },
                          ),
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
                    color: (appState.applicationStyle != null &&
                            this.appState.applicationStyle?.topMenuColor !=
                                null)
                        ? this
                            .appState
                            .applicationStyle
                            .topMenuColor
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
                            color: (appState.applicationStyle != null &&
                                    this
                                            .appState
                                            .applicationStyle
                                            .sideMenuColor !=
                                        null)
                                ? this
                                    .appState
                                    .applicationStyle
                                    .sideMenuColor
                                    .withOpacity(0.95)
                                : Color(0xff171717).withOpacity(0.95),
                            child: widget.menu),
                        Expanded(
                            child: widget.screen != null
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: widget.screen,
                                  )
                                : this.appState.files.containsKey(this
                                        .appState
                                        .applicationStyle
                                        ?.desktopIcon)
                                    ? Container(
                                        decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: MemoryImage(base64Decode(
                                              this.appState.files[this
                                                  .appState
                                                  .applicationStyle
                                                  ?.desktopIcon])),
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
                            decoration: this.appState.files.containsKey(
                                    this.appState.applicationStyle?.desktopIcon)
                                ? BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(base64Decode(
                                          this.appState.files[this
                                              .appState
                                              .applicationStyle
                                              .desktopIcon])),
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
    String username = this.appState.username;
    if (this.appState.displayName != null) username = this.appState.displayName;

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: (appState.applicationStyle != null &&
                this.appState.applicationStyle?.topMenuColor != null)
            ? this.appState.applicationStyle?.topMenuColor.withOpacity(0.95)
            : Color(0xff2196f3).withOpacity(0.95),
      ),
      child: Material(
        shape: CircleBorder(),
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: mypopup.PopupMenuButton<int>(
            hoverColor: Colors.black.withOpacity(0.3),
            itemBuilder: (context) => [
              // mypopup.PopupMenuItem(
              //   enabled: false,
              //   value: 0,
              //   child: SizedBox(
              //     height: 60,
              //     child: Container(
              //       color: (appState.applicationStyle!= null &&
              //               this.appState.applicationStyle?.topMenuColor != null)
              //           ? this.appState.applicationStyle?.topMenuColor.withOpacity(0.95)
              //           : Color(0xff2196f3).withOpacity(0.95),
              //       child: Center(
              //         child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: <Widget>[
              //               this.appState.username.isNotEmpty
              //                   ? Text(
              //                       Translations.of(context)
              //                           .text2('Logged in as', 'Logged in as'),
              //                       style: TextStyle(
              //                           color: UIData.textColor, fontSize: 12),
              //                     )
              //                   : Container(),
              //               SizedBox(
              //                 height: 5,
              //               ),
              //               Text(username ?? '',
              //                   style: TextStyle(color: UIData.textColor)),
              //             ]),
              //       ),
              //     ),
              //   ),
              // ),
              mypopup.PopupMenuStack(
                children: [
                  Container(
                    color: (appState.applicationStyle != null &&
                            this.appState.applicationStyle?.topMenuColor !=
                                null)
                        ? this
                            .appState
                            .applicationStyle
                            .topMenuColor
                            .withOpacity(0.95)
                        : Color(0xff2196f3).withOpacity(0.95),
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            this.appState.username.isNotEmpty
                                ? Text(
                                    AppLocalizations.of(context)
                                        .text('Logged in as'),
                                    style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 12),
                                  )
                                : Container(),
                            SizedBox(
                              height: 15,
                            ),
                            Text(username ?? '',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)),
                          ]),
                    ),
                  ),
                ],
              )
            ],
            icon: CircleAvatar(
              backgroundImage: this.appState.profileImage != null &&
                      this.appState.profileImage.isNotEmpty
                  ? profileImg.image
                  : null,
              child: this.appState.profileImage != null &&
                      this.appState.profileImage.isNotEmpty
                  ? null
                  : FaIcon(
                      FontAwesomeIcons.userTie,
                      color: (appState.applicationStyle != null &&
                              this
                                      .appState
                                      .applicationStyle
                                      ?.topMenuIconColor !=
                                  null)
                          ? this.appState.applicationStyle?.topMenuIconColor
                          : Color(0xffffffff),
                    ),
              radius: 50,
            ),
            offset: Offset(0, 100),
            onSelected: (result) {},
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return BlocBuilder<ApiBloc, Response>(builder: (context, state) {
      if (state.request.requestType == RequestType.LOGOUT &&
          (state.error == null || !state.hasError)) {
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
