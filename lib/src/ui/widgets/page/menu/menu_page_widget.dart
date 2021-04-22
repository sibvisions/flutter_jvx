import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/flutterclient.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/requests/logout_request.dart';
import '../../../../models/api/requests/open_screen_request.dart';
import '../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/arguments/login_page_arguments.dart';
import '../../../../models/state/routes/arguments/open_screen_page_arguments.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../screen/core/manager/so_menu_manager.dart';
import '../../../util/error/custom_bloc_listener.dart';
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

  Size? _lastScreenSize;
  Timer? _deviceStatusTimer;

  void _addDeviceStatusTimer(BuildContext context) {
    Size currentSize = MediaQuery.of(context).size;

    if (_lastScreenSize?.height != currentSize.height ||
        _lastScreenSize?.width != currentSize.width) {
      if (_deviceStatusTimer != null && _deviceStatusTimer!.isActive) {
        _deviceStatusTimer!.cancel();
      }

      _deviceStatusTimer = Timer(const Duration(milliseconds: 300), () {
        DeviceStatusRequest request = DeviceStatusRequest(
            clientId: widget.appState.applicationMetaData!.clientId,
            screenSize: currentSize,
            timeZoneCode: '',
            langCode: '');

        _lastScreenSize = currentSize;

        if (ModalRoute.of(context)!.isCurrent)
          sl<ApiCubit>().deviceStatus(request);
      });
    }
  }

  void onLogout() {
    LogoutRequest logoutRequest =
        LogoutRequest(clientId: widget.appState.applicationMetaData!.clientId);

    sl<ApiCubit>().logout(logoutRequest);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_lastScreenSize == null) {
      _lastScreenSize = MediaQuery.of(context).size;
    }
  }

  @override
  void dispose() {
    _deviceStatusTimer?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    if (!widget.appState.serverConfig!.isPreview) {
      _menuItems = widget.menuItems;
    } else if (widget.menuItems.isNotEmpty) {
      _menuItems = <MenuItem>[widget.menuItems.first];
    } else {
      _menuItems = <MenuItem>[];
    }

    SoMenuManager menuManager = SoMenuManager(_menuItems);

    widget.appState.screenManager.onMenu(menuManager);

    if (widget.appState.listener != null) {
      widget.appState.listener!
          .fireAfterStartupListener(ApplicationApi(context));
    }

    if (widget.appState.socketHandler != null &&
        !widget.appState.socketHandler!.isOn) {
      widget.appState.socketHandler!.initCommunication();
    }

    if (widget.response != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => Navigator.of(context)
          .pushNamed(Routes.openScreen,
              arguments: OpenScreenPageArguments(
                  screen: widget.appState.screenManager
                      .createScreen(response: widget.response!))));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _addDeviceStatusTimer(context);

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
            ScreenGenericResponseObject? screenGeneric =
                state.getObjectByType<ScreenGenericResponseObject>();

            if (screenGeneric != null) {
              if (widget.appState.screenManager.hasScreen(
                  (state.request as OpenScreenRequest).componentId)) {
                widget.appState.screenManager
                    .findScreen(
                        (state.request as OpenScreenRequest).componentId)!
                    .configuration
                    .value = state;

                Navigator.of(context).pushNamed(Routes.openScreen,
                    arguments: OpenScreenPageArguments(
                        screen: widget.appState.screenManager.findScreen(
                            (state.request as OpenScreenRequest)
                                .componentId)!));
              } else {
                Navigator.of(context).pushNamed(Routes.openScreen,
                    arguments: OpenScreenPageArguments(
                        screen: widget.appState.screenManager
                            .createScreen(response: state)));
              }
            }
          }
        }
      },
      child: Builder(
        builder: (context) {
          if (widget.appState.webOnly) {
            return BrowserMenuWidget(
              cubit: sl<ApiCubit>(),
              listMenuItemsInDrawer: widget.listMenuItemsInDrawer,
              appState: widget.appState,
              menuItems: _menuItems,
              onLogoutPressed: () {},
            );
          } else if (widget.appState.mobileOnly) {
            return MobileMenuWidget(
              cubit: sl<ApiCubit>(),
              appState: widget.appState,
              menuItems: _menuItems,
              listMenuItemsInDrawer: widget.listMenuItemsInDrawer,
              onLogoutPressed: onLogout,
            );
          } else {
            return OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                if (orientation == Orientation.landscape && kIsWeb) {
                  return BrowserMenuWidget(
                      cubit: sl<ApiCubit>(),
                      listMenuItemsInDrawer: widget.listMenuItemsInDrawer,
                      appState: widget.appState,
                      menuItems: _menuItems,
                      onLogoutPressed: onLogout);
                } else {
                  return MobileMenuWidget(
                      cubit: sl<ApiCubit>(),
                      appState: widget.appState,
                      menuItems: _menuItems,
                      listMenuItemsInDrawer: widget.listMenuItemsInDrawer,
                      onLogoutPressed: onLogout);
                }
              },
            );
          }
        },
      ),
    );
  }
}
