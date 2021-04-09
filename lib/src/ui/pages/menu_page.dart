import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/api/response_objects/menu/menu_item.dart';
import '../../models/state/app_state.dart';
import '../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../services/remote/cubit/api_cubit.dart';
import '../../util/theme/theme_manager.dart';
import '../widgets/page/menu/menu_page_widget.dart';

class MenuPage extends StatelessWidget {
  final bool listMenuItemsInDrawer;
  final List<MenuItem> menuItems;
  final ApiResponse? response;
  final AppState appState;
  final SharedPreferencesManager manager;

  const MenuPage(
      {Key? key,
      required this.listMenuItemsInDrawer,
      required this.menuItems,
      required this.appState,
      required this.manager,
      this.response})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Theme(
          data: sl<ThemeManager>().value,
          child: MenuPageWidget(
            menuItems: menuItems,
            listMenuItemsInDrawer: listMenuItemsInDrawer,
            response: response,
            appState: appState,
            manager: manager,
          )),
    );
  }
}
