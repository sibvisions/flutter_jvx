import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/requests/open_screen_request.dart';
import 'package:flutterclient/src/models/api/response_objects/menu/menu_item.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/models/state/routes/arguments/open_screen_page_arguments.dart';
import 'package:flutterclient/src/models/state/routes/routes.dart';
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart';
import 'package:flutterclient/src/ui/widgets/page/menu/browser/navigation_bar_widget.dart';

import '../../../../../injection_container.dart';

class BrowserMenuWidget extends StatefulWidget {
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

      sl<ApiCubit>().openScreen(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarWidget(
      onMenuItemPressed: _onPressedMenuItem,
      appState: widget.appState,
      onLogoutPressed: widget.onLogoutPressed,
      menuItems: widget.menuItems,
      child: Center(
        child: Text('HELLO'),
      ),
    );
  }
}
