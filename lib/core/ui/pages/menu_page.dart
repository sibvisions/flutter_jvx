import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart';
import '../../models/api/response.dart';
import '../../models/api/response/menu_item.dart';
import '../../models/app/app_state.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/theme/theme_manager.dart';
import '../widgets/page/menu_page_widget.dart';
import '../widgets/util/app_state_provider.dart';

class MenuPage extends StatelessWidget {
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;
  final Response welcomeScreen;

  const MenuPage(
      {Key key, this.menuItems, this.listMenuItemsInDrawer, this.welcomeScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppState appState = AppStateProvider.of(context).appState;

    return Theme(
      data: sl<ThemeManager>().themeData,
      child: BlocProvider<ApiBloc>(
        create: (_) => sl<ApiBloc>(),
        child: MenuPageWidget(
          listMenuItemsInDrawer: this.listMenuItemsInDrawer,
          menuItems: this.menuItems,
          welcomeScreen: this.welcomeScreen,
          appState: appState,
        ),
      ),
    );
  }
}
