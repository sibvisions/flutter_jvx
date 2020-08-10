import 'dart:io';
import 'dart:convert' as utf8;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/custom_screen/app_frame.dart';
import 'package:jvx_flutterclient/logic/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/model/api/request/device_Status.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/api/response/response.dart';
import 'package:jvx_flutterclient/ui/widgets/web_menu_list_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../logic/bloc/error_handler.dart';
import '../../utils/application_api.dart';
import '../screen/so_menu_manager.dart';
import '../../ui/widgets/menu_empty_widget.dart';
import '../../model/menu_item.dart';
import '../../ui/widgets/menu_drawer_widget.dart';
import '../../ui/widgets/menu_grid_view.dart';
import '../../ui/widgets/menu_list_widget.dart';
import '../../ui/widgets/menu_swiper_widget.dart';
import '../../ui/widgets/menu_tabs_widget.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/uidata.dart';

class MenuPage extends StatefulWidget {
  List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;
  MenuPage({Key key, List<MenuItem> menuItems, this.listMenuItemsInDrawer})
      : this.menuItems = menuItems,
        super(key: key) {
    if (globals.appMode == 'preview' &&
        this.menuItems != null &&
        this.menuItems.length > 1) {
      this.menuItems = [this.menuItems[0]];
    }
  }

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  double width;

  double height;

  Orientation lastOrientation;

  bool get hasMultipleGroups {
    int groupCount = 0;
    String lastGroup = "";
    if (this.widget.menuItems != null) {
      this.widget.menuItems?.forEach((m) {
        if (m.group != lastGroup) {
          groupCount++;
          lastGroup = m.group;
        }
      });
    }
    return (groupCount > 1);
  }

  Color get backgroundColor {
    if (globals.applicationStyle != null &&
        globals.applicationStyle.desktopColor != null) {
      return globals.applicationStyle.desktopColor;
    }

    return Colors.grey.shade200;
  }

  String get menuMode {
    if (globals.applicationStyle != null &&
        globals.applicationStyle.menuMode != null)
      return globals.applicationStyle.menuMode;
    else
      return 'grid';
  }

  bool get groupedMenuMode {
    return (menuMode == 'grid_grouped' || menuMode == 'list') &
        hasMultipleGroups;
  }

  @override
  Widget build(BuildContext context) {
    if (lastOrientation == null) {
      lastOrientation = MediaQuery.of(context).orientation;
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    } else if (lastOrientation != MediaQuery.of(context).orientation ||
        width != MediaQuery.of(context).size.width ||
        height != MediaQuery.of(context).size.height) {
      DeviceStatus status = DeviceStatus(
          screenSize: MediaQuery.of(context).size,
          timeZoneCode: "",
          langCode: "");
      BlocProvider.of<ApiBloc>(context).dispatch(status);
      lastOrientation = MediaQuery.of(context).orientation;
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    }

    // Custom Screen
    if (globals.customScreenManager != null) {
      SoMenuManager menuManager = SoMenuManager(this.widget.menuItems);
      globals.customScreenManager.onMenu(menuManager);
      this.widget.menuItems = menuManager.menuItems;
    }

    if (globals.appListener != null) {
      globals.appListener.fireAfterStartupListener(ApplicationApi(context));
    }

    if (globals.customSocketHandler != null) {
      // initialize the Websocket Communication
      globals.customSocketHandler.initCommunication();
    }

    //AppFrame
    if (globals.appFrame is AppFrame || globals.appFrame == null) {
      globals.appFrame = AppFrame(context);
    }

    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    globals.items = this.widget.menuItems;

    Widget body;

    if ((globals.applicationStyle != null &&
        globals.applicationStyle?.desktopIcon != null)) {
      body = Container(
          decoration: BoxDecoration(
              image: !kIsWeb
                  ? DecorationImage(
                      image: FileImage(File(
                          '${globals.dir}${globals.applicationStyle.desktopIcon}')),
                      fit: BoxFit.cover)
                  : DecorationImage(
                      image: globals.files
                              .containsKey(globals.applicationStyle.desktopIcon)
                          ? MemoryImage(utf8.base64Decode(globals
                              .files[globals.applicationStyle.desktopIcon]))
                          : null,
                      fit: BoxFit.cover,
                    )),
          child: getMenuWidget(context));
    } else {
      body = getMenuWidget(context);
    }

    return errorAndLoadingListener(BlocListener<ApiBloc, Response>(
      listener: (context, state) {
        print("*** MenuPage - RequestType: " + state.requestType.toString());
        if (state != null &&
            state.deviceStatus != null &&
            state.deviceStatus.layoutMode != null &&
            state.requestType == RequestType.DEVICE_STATUS) {
          globals.layoutMode = state.deviceStatus.layoutMode;
          this.setState(() {});
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: globals.appFrame.showScreenHeader
            ? AppBar(
                backgroundColor: UIData.ui_kit_color_2,
                title: Text('Menu'),
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openEndDrawer();
                    },
                    icon: Icon(FontAwesomeIcons.ellipsisV),
                  ),
                ],
              )
            : null,
        body:
            FractionallySizedBox(widthFactor: 1, heightFactor: 1, child: body),
        endDrawer: globals.appFrame.showScreenHeader
            ? MenuDrawerWidget(
                menuItems: this.widget.menuItems,
                listMenuItems: true,
                groupedMenuMode: groupedMenuMode,
              )
            : null,
      ),
    ));
  }

  Widget getMenuWidget(BuildContext context) {
    globals.appFrame.screen = null;

    if (globals.appFrame.isWeb) {
      globals.appFrame.setMenu(WebMenuListWidget(
          menuItems: this.widget.menuItems,
          groupedMenuMode: hasMultipleGroups));
    } else {
      switch (menuMode) {
        case 'grid':
          globals.appFrame.setMenu(MenuGridView(
              items: this.widget.menuItems, groupedMenuMode: false));
          break;
        case 'list':
          globals.appFrame.setMenu(MenuListWidget(
              menuItems: this.widget.menuItems,
              groupedMenuMode: hasMultipleGroups));
          break;
        case 'drawer':
          globals.appFrame.setMenu(MenuEmpty());
          break;
        case 'grid_grouped':
          globals.appFrame.setMenu(MenuGridView(
            items: this.widget.menuItems,
            groupedMenuMode: hasMultipleGroups,
          ));
          break;
        case 'swiper':
          globals.appFrame.setMenu(MenuSwiperWidget(
            items: this.widget.menuItems,
            groupedMenuMode: hasMultipleGroups,
          ));
          break;
        case 'tabs':
          globals.appFrame.setMenu(MenuTabsWidget(
            items: this.widget.menuItems,
            groupedMenuMode: hasMultipleGroups,
          ));
          break;
        default:
          globals.appFrame.setMenu(MenuGridView(
            items: this.widget.menuItems,
            groupedMenuMode: hasMultipleGroups,
          ));
          break;
      }
    }
    return globals.appFrame.getWidget();
  }
}
