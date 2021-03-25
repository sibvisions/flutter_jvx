import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterclient/src/ui/screen/core/manager/so_menu_manager.dart';
import 'package:flutterclient/src/ui/util/error/custom_bloc_listener.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/requests/logout_request.dart';
import '../../../../models/api/requests/open_screen_request.dart';
import '../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/arguments/login_page_arguments.dart';
import '../../../../models/state/routes/arguments/open_screen_page_arguments.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../util/error/error_handler.dart';
import 'browser_menu_widget.dart';
import 'mobile_menu_widget.dart';

class MenuPageWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;
  final ApiResponse? response;
  final AppState appState;
  final SharedPreferencesManager manager;

  const MenuPageWidget({
    Key? key,
    required this.menuItems,
    required this.listMenuItemsInDrawer,
    required this.appState,
    required this.manager,
    this.response,
  }) : super(key: key);

  @override
  _MenuPageWidgetState createState() => _MenuPageWidgetState();
}

class _MenuPageWidgetState extends State<MenuPageWidget> {
  List<MenuItem> _menuItems = <MenuItem>[];

  @override
  void initState() {
    if (widget.appState.screenManager != null) {
      SoMenuManager menuManager = SoMenuManager(widget.menuItems);

      widget.appState.screenManager!.onMenu(menuManager);
      _menuItems = menuManager.menuItems;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCubitListener(
      appState: widget.appState,
      bloc: sl<ApiCubit>(),
      listener: (context, state) async {
        if (state is ApiResponse) {
          if (state.request is LogoutRequest) {
            Navigator.of(context).pushReplacementNamed(Routes.login,
                arguments: LoginPageArguments(
                    lastUsername: widget.appState.userData?.username ?? ''));
          } else if (state.request is OpenScreenRequest) {
            Navigator.of(context).pushNamed(Routes.openScreen,
                arguments: OpenScreenPageArguments(response: state));
          }
        } else if (state is ApiError) {
          await ErrorHandler.handleError(state, context);
        }
      },
      child: Builder(
        builder: (context) {
          if (widget.manager.webOnly) {
            return BrowserMenuWidget();
          } else if (widget.manager.mobileOnly) {
            return MobileMenuWidget(
              appState: widget.appState,
              menuItems: _menuItems,
              listMenuItemsInDrawer: widget.listMenuItemsInDrawer,
              onLogoutPressed: () {
                LogoutRequest logoutRequest = LogoutRequest(
                    clientId: widget.appState.applicationMetaData!.clientId);

                sl<ApiCubit>().logout(logoutRequest);
              },
            );
          } else {
            return OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                if (orientation == Orientation.landscape) {
                  return BrowserMenuWidget();
                } else {
                  return MobileMenuWidget(
                    appState: widget.appState,
                    menuItems: _menuItems,
                    listMenuItemsInDrawer: widget.listMenuItemsInDrawer,
                    onLogoutPressed: () {
                      LogoutRequest logoutRequest = LogoutRequest(
                          clientId:
                              widget.appState.applicationMetaData!.clientId);

                      sl<ApiCubit>().logout(logoutRequest);
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
