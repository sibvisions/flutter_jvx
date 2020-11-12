import 'package:flutter/material.dart';

import '../../models/api/response/menu_item.dart';
import '../../models/app/app_state.dart';
import '../../ui/widgets/menu/menu_empty.dart';
import '../../ui/widgets/menu/menu_grid_view.dart';
import '../../ui/widgets/menu/menu_list_widget.dart';
import '../../ui/widgets/menu/menu_swiper_right.dart';
import '../../ui/widgets/menu/menu_tabs_widget.dart';
import '../../ui/widgets/web/web_menu_list_widget.dart';

Widget getMenuWidget(BuildContext context, AppState appState,
    bool hasMultipleGroups, Function(MenuItem) onPressed, String menuMode) {
  appState.appFrame.screen = null;

  if (!appState.appFrame.showScreenHeader) {
    appState.appFrame.setMenu(WebMenuListWidget(
      menuItems: appState.items,
      groupedMenuMode: hasMultipleGroups,
      onPressed: onPressed,
      appState: appState,
    ));
  } else {
    switch (menuMode) {
      case 'grid':
        appState.appFrame.setMenu(MenuGridView(
          items: appState.items,
          groupedMenuMode: false,
          onPressed: onPressed,
          appState: appState,
        ));
        break;
      case 'list':
        appState.appFrame.setMenu(MenuListWidget(
          menuItems: appState.items,
          groupedMenuMode: hasMultipleGroups,
          onPressed: onPressed,
          appState: appState,
        ));
        break;
      case 'drawer':
        appState.appFrame.setMenu(MenuEmpty());
        break;
      case 'grid_grouped':
        appState.appFrame.setMenu(MenuGridView(
            items: appState.items,
            groupedMenuMode: hasMultipleGroups,
            onPressed: onPressed,
            appState: appState));
        break;
      case 'swiper':
        appState.appFrame.setMenu(MenuSwiperWidget(
            items: appState.items,
            groupedMenuMode: hasMultipleGroups,
            onPressed: onPressed,
            appState: appState));
        break;
      case 'tabs':
        appState.appFrame.setMenu(MenuTabsWidget(
            items: appState.items,
            groupedMenuMode: hasMultipleGroups,
            onPressed: onPressed,
            appState: appState));
        break;
      default:
        appState.appFrame.setMenu(MenuGridView(
            items: appState.items,
            groupedMenuMode: hasMultipleGroups,
            onPressed: onPressed,
            appState: appState));
        break;
    }
  }
  return appState.appFrame.getWidget();
}
