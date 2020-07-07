import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/utils/app_api.dart';

import '../../ui/screen/menu_manager.dart';
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
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Custom Screen
    if (globals.customScreenManager != null) {
      JVxMenuManager menuManager = JVxMenuManager(this.menuItems);
      globals.customScreenManager.onMenu(menuManager);
      this.menuItems = menuManager.menuItems;
    }

    globals.appListener.fireAfterStartupListener(AppApi(context));

    if (globals.customSocketHandler != null) {
      // initialize the Websocket Communication
      globals.customSocketHandler.initCommunication();
    }

    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    globals.items = this.menuItems;

    Widget body;

    if ((globals.applicationStyle != null &&
        globals.applicationStyle?.desktopIcon != null)) {
      body = Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(File(
                      '${globals.dir}${globals.applicationStyle.desktopIcon}')),
                  fit: BoxFit.cover)),
          child: getMenuWidget());
    } else {
      body = getMenuWidget();
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
      ),
      body: FractionallySizedBox(widthFactor: 1, heightFactor: 1, child: body),
      endDrawer: MenuDrawerWidget(
        menuItems: this.menuItems,
        listMenuItems: true,
        groupedMenuMode: groupedMenuMode,
      ),
    );
  }

  Widget getMenuWidget() {
    switch (menuMode) {
      case 'grid':
        return MenuGridView(items: this.menuItems, groupedMenuMode: false);
      case 'list':
        return MenuListWidget(
            menuItems: this.menuItems,
            groupedMenuMode: hasMultipleGroups);
      case 'drawer':
        return MenuEmpty();
      case 'grid_grouped':
        return MenuGridView(
          items: this.menuItems,
          groupedMenuMode: hasMultipleGroups,
        );
      case 'swiper':
        return MenuSwiperWidget(
          items: this.menuItems,
          groupedMenuMode: hasMultipleGroups,
        );
      case 'tabs':
        return MenuTabsWidget(
          items: this.menuItems,
          groupedMenuMode: hasMultipleGroups,
        ); 
      default:
        return MenuGridView(
          items: this.menuItems,
          groupedMenuMode: hasMultipleGroups,
        );
    }
  }
}
