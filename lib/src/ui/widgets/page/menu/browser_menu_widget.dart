import 'package:flutter/material.dart';

import '../../../../models/api/requests/open_screen_request.dart';
import '../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/arguments/open_screen_page_arguments.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import 'browser/navigation_bar_widget.dart';

class BrowserMenuWidget extends StatefulWidget {
  final ApiCubit cubit;
  final AppState appState;
  final Function onLogoutPressed;
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;

  const BrowserMenuWidget({
    Key? key,
    required this.appState,
    required this.onLogoutPressed,
    required this.menuItems,
    required this.listMenuItemsInDrawer,
    required this.cubit,
  }) : super(key: key);

  @override
  _BrowserMenuWidgetState createState() => _BrowserMenuWidgetState();
}

class _BrowserMenuWidgetState extends State<BrowserMenuWidget> {
  void _onPressedMenuItem(MenuItem menuItem) {
    if (widget.appState.screenManager.hasScreen(menuItem.componentId) &&
        !widget.appState.screenManager
            .findScreen(menuItem.componentId)!
            .configuration
            .withServer) {
      Navigator.of(context).pushNamed(Routes.openScreen,
          arguments: OpenScreenPageArguments(
              screen: widget.appState.screenManager
                  .findScreen(menuItem.componentId)!));
    } else {
      OpenScreenRequest request = OpenScreenRequest(
          clientId: widget.appState.applicationMetaData!.clientId,
          componentId: menuItem.componentId);

      widget.cubit.openScreen(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarWidget(
        onMenuItemPressed: _onPressedMenuItem,
        appState: widget.appState,
        onLogoutPressed: widget.onLogoutPressed,
        menuItems: widget.menuItems,
        child: Container());
  }
}
