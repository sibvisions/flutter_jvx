import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/requests/close_screen_request.dart';
import 'package:flutterclient/src/models/api/requests/device_status_request.dart';
import 'package:flutterclient/src/models/api/requests/navigation_request.dart';
import 'package:flutterclient/src/models/api/response_objects/close_screen_action_response_object.dart';
import 'package:flutterclient/src/util/app/listener/listener.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/requests/data/data_request.dart';
import '../../../../models/api/requests/logout_request.dart';
import '../../../../models/api/requests/open_screen_request.dart';
import '../../../../models/api/requests/press_button_request.dart';
import '../../../../models/api/response_objects/device_status_response_object.dart';
import '../../../../models/api/response_objects/device_status_response_object.dart';
import '../../../../models/api/response_objects/download_action_response_object.dart';
import '../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../../models/api/response_objects/upload_action_response_object.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/arguments/login_page_arguments.dart';
import '../../../../models/state/routes/default_page.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../screen/core/configuration/so_screen_configuration.dart';
import '../../../screen/core/so_component_creator.dart';
import '../../../screen/core/so_screen.dart';
import '../../../util/error/custom_bloc_listener.dart';
import '../../drawer/menu_drawer_widget.dart';

class OpenScreenPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final ApiResponse response;

  const OpenScreenPageWidget({
    Key? key,
    required this.appState,
    required this.manager,
    required this.response,
  }) : super(key: key);

  @override
  _OpenScreenPageWidgetState createState() => _OpenScreenPageWidgetState();
}

class _OpenScreenPageWidgetState extends State<OpenScreenPageWidget>
    with WidgetsBindingObserver {
  List<DefaultPage> _pages = <DefaultPage>[];

  late String _currentComponentId;
  late ApiResponse _response;

  late Size _lastScreenSize;
  late Timer _deviceStatusTimer;

  void _listener(BuildContext context, ApiState state) {
    if (state is ApiResponse) {
      _response = state;

      _pages.forEach(
          (page) => (page.child as SoScreen).configuration.value = state);

      if (state.request is LogoutRequest) {
        Navigator.of(context).pushNamed(Routes.login,
            arguments: LoginPageArguments(lastUsername: ''));
      } else if (state.request is NavigationRequest) {
        _pages.removeLast();

        if (_pages.isEmpty) {
          Navigator.of(context).pop();
        }
      } else if (state.request is CloseScreenRequest) {
        _pages.removeLast();

        if (_pages.isEmpty) {
          Navigator.of(context).pop();
        }
      } else if (state.request is OpenScreenRequest) {
        if (state.hasObject<ScreenGenericResponseObject>()) {
          setState(() {
            addPage(_createScreen(state));
          });
        }
      }

      if (state.hasObject<CloseScreenActionResponseObject>()) {
        setState(() {
          _pages.removeWhere((page) =>
              (page.child as SoScreen).configuration.componentId ==
              state
                  .getObjectByType<CloseScreenActionResponseObject>()!
                  .componentId);
        });
      }

      if (state.hasObject<DeviceStatusResponseObject>()) {
        setState(() {
          widget.appState.deviceStatus =
              state.getObjectByType<DeviceStatusResponseObject>()!;
        });
      }

      if (state.hasObject<DownloadActionResponseObject>()) {}

      if (state.hasObject<UploadActionResponseObject>()) {}
    }
  }

  void addPage(SoScreen screen) {
    _pages.add(DefaultPage(
        name: screen.configuration.componentId,
        arguments: screen.configuration.value,
        key: ValueKey(screen.configuration.componentId),
        child: screen));
  }

  void addAllScreens(List<SoScreen> screensToAdd) {
    if (screensToAdd.isNotEmpty) {
      screensToAdd.forEach((screen) => addPage(screen));
    }
  }

  bool _onPopPage(Route<dynamic> route, dynamic sendNavigation) {
    try {
      if (!route.didPop(route)) {
        return false;
      }

      if (sendNavigation is bool && !sendNavigation) {
        return true;
      }

      NavigationRequest request = NavigationRequest(
          clientId: widget.appState.applicationMetaData!.clientId,
          componentId:
              (_pages.last.child as SoScreen).configuration.componentId);

      sl<ApiCubit>().navigation(request);

      return false;
    } catch (e) {
      NavigationRequest request = NavigationRequest(
          clientId: widget.appState.applicationMetaData!.clientId,
          componentId:
              (_pages.last.child as SoScreen).configuration.componentId);

      sl<ApiCubit>().navigation(request);

      return false;
    }
  }

  void _onLogoutPressed() {
    LogoutRequest request =
        LogoutRequest(clientId: widget.appState.applicationMetaData!.clientId);

    sl<ApiCubit>().logout(request);
  }

  void _onMenuItemPressed(MenuItem menuItem) {
    if (menuItem.componentId != widget.appState.currentMenuComponentId) {
      OpenScreenRequest request = OpenScreenRequest(
          clientId: widget.appState.applicationMetaData!.clientId,
          componentId: menuItem.componentId);

      sl<ApiCubit>().openScreen(request);
    }
  }

  void _addInitialScreen(ApiResponse response) {
    _response = widget.response;

    _currentComponentId =
        response.getObjectByType<ScreenGenericResponseObject>()!.screenTitle ??
            '';

    addPage(_createScreen(response));
  }

  SoScreen _createScreen(ApiResponse response) {
    ScreenGenericResponseObject? screenGeneric =
        response.getObjectByType<ScreenGenericResponseObject>();

    SoScreen screen = SoScreen(
      creator: SoComponentCreator(),
      drawer: MenuDrawerWidget(
        appState: widget.appState,
        menuItems: widget.appState.menuResponseObject.entries,
        onLogoutPressed: _onLogoutPressed,
        onMenuItemPressed: _onMenuItemPressed,
        onSettingsPressed: () =>
            Navigator.of(context).pushNamed(Routes.settings),
        title: screenGeneric!.screenTitle!,
      ),
      configuration: SoScreenConfiguration(
        componentId: screenGeneric.componentId!,
        response: response,
        screenTitle: screenGeneric.screenTitle!,
      ),
    );

    return screen;
  }

  void _addDeviceStatusTimer(BuildContext context) {
    Size currentSize = MediaQuery.of(context).size;

    if (_lastScreenSize.height != currentSize.height ||
        _lastScreenSize.width != currentSize.width) {
      if (_deviceStatusTimer.isActive) {
        _deviceStatusTimer.cancel();
      }

      _deviceStatusTimer = Timer(const Duration(milliseconds: 300), () {
        DeviceStatusRequest request = DeviceStatusRequest(
            clientId: widget.appState.applicationMetaData!.clientId,
            screenSize: currentSize,
            timeZoneCode: '',
            langCode: '');

        _lastScreenSize = currentSize;

        sl<ApiCubit>().deviceStatus(request);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.appState.listener != null) {
      widget.appState.listener!
          .fireAfterStartupListener(ApplicationApi(context));
    }

    _addInitialScreen(widget.response);

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _lastScreenSize = MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _addDeviceStatusTimer(context);

    return GestureDetector(
      onTap: () => TextUtils.unfocusCurrentTextfield(context),
      child: CustomCubitListener(
        appState: widget.appState,
        bloc: sl<ApiCubit>(),
        listener: _listener,
        child: _pages.isNotEmpty
            ? Navigator(
                pages: [
                  if (_pages.isNotEmpty) _pages.first,
                  if (_pages.isNotEmpty && _pages.indexOf(_pages.last) > 0)
                    _pages.last,
                ],
                onPopPage: _onPopPage,
              )
            : Container(),
      ),
    );
  }
}
