import 'dart:io';
import 'dart:convert' as utf8;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/custom_screen/app_frame.dart';
import 'package:jvx_flutterclient/ui/widgets/web_menu_list_widget.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

class MenuPage extends StatelessWidget {
  List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;

  bool get hasMultipleGroups {
    int groupCount = 0;
    String lastGroup = "";
    if (this.menuItems != null) {
      this.menuItems?.forEach((m) {
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
  Widget build(BuildContext context) {
    // Custom Screen
    if (globals.customScreenManager != null) {
      SoMenuManager menuManager = SoMenuManager(this.menuItems);
      globals.customScreenManager.onMenu(menuManager);
      this.menuItems = menuManager.menuItems;
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
    globals.items = this.menuItems;

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

    return Scaffold(
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
      body: FractionallySizedBox(widthFactor: 1, heightFactor: 1, child: body),
      endDrawer: globals.appFrame.showScreenHeader
          ? MenuDrawerWidget(
              menuItems: this.menuItems,
              listMenuItems: true,
              groupedMenuMode: groupedMenuMode,
            )
          : null,
    );
  }

  Widget getMenuWidget(BuildContext context) {
    globals.appFrame.screen = null;

    var deviceType = getDeviceType(MediaQuery.of(context).size);
    if (deviceType == DeviceScreenType.desktop && !globals.mobileOnly) {
      globals.appFrame.setMenu(WebMenuListWidget(
          menuItems: this.menuItems, groupedMenuMode: hasMultipleGroups));
    } else {
      switch (menuMode) {
        case 'grid':
          globals.appFrame.setMenu(
              MenuGridView(items: this.menuItems, groupedMenuMode: false));
          break;
        case 'list':
          globals.appFrame.setMenu(MenuListWidget(
              menuItems: this.menuItems, groupedMenuMode: hasMultipleGroups));
          break;
        case 'drawer':
          globals.appFrame.setMenu(MenuEmpty());
          break;
        case 'grid_grouped':
          globals.appFrame.setMenu(MenuGridView(
            items: this.menuItems,
            groupedMenuMode: hasMultipleGroups,
          ));
          break;
        case 'swiper':
          globals.appFrame.setMenu(MenuSwiperWidget(
            items: this.menuItems,
            groupedMenuMode: hasMultipleGroups,
          ));
          break;
        case 'tabs':
          globals.appFrame.setMenu(MenuTabsWidget(
            items: this.menuItems,
            groupedMenuMode: hasMultipleGroups,
          ));
          break;
        default:
          globals.appFrame.setMenu(MenuGridView(
            items: this.menuItems,
            groupedMenuMode: hasMultipleGroups,
          ));
          break;
      }
    }
    return globals.appFrame.getWidget();
  }
}
