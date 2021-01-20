import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/i_offline_database_provider.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/offline_database.dart';
import 'package:jvx_flutterclient/core/services/local/local_database_manager.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/restart_widget.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/shared_pref_provider.dart';
import 'package:jvx_flutterclient/core/utils/network/network_info.dart';

import '../../../../injection_container.dart';
import '../../../models/api/request.dart';
import '../../../models/api/request/device_status.dart';
import '../../../models/api/request/menu.dart';
import '../../../models/api/request/open_screen.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/menu_item.dart';
import '../../../models/api/so_action.dart';
import '../../../models/app/app_state.dart';
import '../../../models/app/screen_arguments.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/get_menu_widget.dart';
import '../../../utils/app/listener/application_api.dart';
import '../../frames/app_frame.dart';
import '../../pages/open_screen_page.dart';
import '../../screen/so_menu_manager.dart';
import '../../screen/so_screen.dart';
import '../dialogs/dialogs.dart';
import '../menu/menu_drawer_widget.dart';
import '../util/error_handling.dart';

class MenuPageWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;
  final Response welcomeScreen;
  final AppState appState;

  const MenuPageWidget(
      {Key key,
      this.menuItems,
      this.listMenuItemsInDrawer,
      this.welcomeScreen,
      this.appState})
      : super(key: key);

  @override
  _MenuPageWidgetState createState() => _MenuPageWidgetState();
}

class _MenuPageWidgetState extends State<MenuPageWidget> {
  List<MenuItem> items;

  double width;
  double height;

  Orientation lastOrientation;

  RestartableTimer _deviceStatusTimer;

  String title;

  bool get hasMultipleGroups {
    int groupCount = 0;
    String lastGroup = "";
    if (this.items != null) {
      this.items?.forEach((m) {
        if (m.group != lastGroup) {
          groupCount++;
          lastGroup = m.group;
        }
      });
    }
    return (groupCount > 1);
  }

  Color get backgroundColor {
    if (widget.appState.applicationStyle != null &&
        widget.appState.applicationStyle?.desktopColor != null) {
      return widget.appState.applicationStyle?.desktopColor;
    }

    return Colors.grey.shade200;
  }

  String get menuMode {
    if (widget.appState.applicationStyle != null &&
        widget.appState.applicationStyle?.menuMode != null)
      return widget.appState.applicationStyle?.menuMode;
    else
      return 'grid';
  }

  bool get groupedMenuMode {
    return (menuMode == 'grid_grouped' || menuMode == 'list') &
        hasMultipleGroups;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    this.items = widget.menuItems;

    if (widget.appState.appMode == 'preview' &&
        this.items != null &&
        this.items.length > 1) {
      this.items = [this.items[0]];
    }

    SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
            primaryColor: Theme.of(context).primaryColor.value,
            label: widget.appState.appName ??
                '' + ' - ' + widget.appState.username ??
                ''));

    if (widget.appState.appListener != null) {
      widget.appState.appListener
          .fireAfterStartupListener(ApplicationApi(context));
    }

    if (widget.appState.customSocketHandler != null &&
        !widget.appState.customSocketHandler.isOn) {
      widget.appState.customSocketHandler.initCommunication();
    }

    if (widget.welcomeScreen != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(
          OpenScreenPage.route,
          arguments: ScreenArguments(
            response: widget.welcomeScreen,
            menuComponentId: widget.menuItems
                .firstWhere(
                    (item) => item.text.contains(widget
                        .welcomeScreen.responseData.screenGeneric.screenTitle),
                    orElse: () => null)
                ?.componentId,
            items: widget.menuItems,
            title: widget.welcomeScreen.responseData.screenGeneric.screenTitle,
          ),
        );
      });
    }
  }

  _addDeviceStatusTimer(BuildContext context) {
    if (lastOrientation == null) {
      lastOrientation = MediaQuery.of(context).orientation;
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    } else if (lastOrientation != MediaQuery.of(context).orientation ||
        width != MediaQuery.of(context).size.width ||
        height != MediaQuery.of(context).size.height) {
      DeviceStatus deviceStatus = DeviceStatus(
          screenSize: MediaQuery.of(context).size,
          timeZoneCode: '',
          langCode: '',
          clientId: widget.appState.clientId);

      BlocProvider.of<ApiBloc>(context).add(deviceStatus);
      lastOrientation = MediaQuery.of(context).orientation;
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;

      // if (_deviceStatusTimer == null) {
      //   _deviceStatusTimer = RestartableTimer(const Duration(seconds: 50), () {
      //     DeviceStatus deviceStatus = DeviceStatus(
      //         screenSize: MediaQuery.of(context).size,
      //         timeZoneCode: '',
      //         langCode: '',
      //         clientId: widget.appState.clientId);

      //     BlocProvider.of<ApiBloc>(context).add(deviceStatus);
      //     lastOrientation = MediaQuery.of(context).orientation;
      //     width = MediaQuery.of(context).size.width;
      //     height = MediaQuery.of(context).size.height;

      //     _deviceStatusTimer.cancel();
      //     _deviceStatusTimer = null;
      //   });
      // } else {
      //   _deviceStatusTimer.reset();
      // }
    }
  }

  _screenManager() {
    if (widget.appState.screenManager != null) {
      SoMenuManager menuManager =
          SoMenuManager(widget.appState.isOffline ? <MenuItem>[] : this.items);
      widget.appState.screenManager.onMenu(menuManager);
      this.items = menuManager.menuItems;
    }
    SharedPrefProvider.of(context).manager.setMenuItems(this.items);
  }

  _appFrame() {
    if (widget.appState.appFrame is AppFrame ||
        widget.appState.appFrame == null) {
      widget.appState.appFrame = AppFrame(context);
    }
  }

  _listener() {
    if (widget.appState.appListener != null) {
      widget.appState.appListener.fireOnUpdateListener(context);
    }
  }

  _onPressed(MenuItem menuItem) {
    SoScreen toOpenScreen =
        widget.appState.screenManager.findScreen(menuItem.componentId);

    if (widget.appState.screenManager != null &&
        toOpenScreen != null &&
        toOpenScreen.configuration != null &&
        !toOpenScreen.configuration.withServer) {
      Navigator.pushReplacementNamed(context, OpenScreenPage.route,
          arguments: ScreenArguments(
              items: widget.menuItems,
              menuComponentId: menuItem.componentId,
              title: menuItem.text));
    } else if (toOpenScreen != null &&
        toOpenScreen.configuration != null &&
        toOpenScreen.configuration.withServer &&
        widget.appState.isOffline) {
      Navigator.pushReplacementNamed(context, OpenScreenPage.route,
          arguments: ScreenArguments(
              items: widget.menuItems,
              menuComponentId: menuItem.componentId,
              title: menuItem.text));
    } else {
      SoAction action =
          SoAction(componentId: menuItem.componentId, label: menuItem.text);

      this.title = action.label;

      OpenScreen openScreen = OpenScreen(
        action: action,
        clientId: widget.appState.clientId,
        manualClose: false,
        requestType: RequestType.OPEN_SCREEN,
      );

      BlocProvider.of<ApiBloc>(context).add(openScreen);
    }
  }

  @override
  void initState() {
    super.initState();

    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   DeviceStatus deviceStatus = DeviceStatus(
    //       screenSize: MediaQuery.of(context).size,
    //       timeZoneCode: '',
    //       langCode: '',
    //       clientId: widget.appState.clientId);

    //   BlocProvider.of<ApiBloc>(context).add(deviceStatus);
    //   lastOrientation = MediaQuery.of(context).orientation;
    //   width = MediaQuery.of(context).size.width;
    //   height = MediaQuery.of(context).size.height;
    // });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    _addDeviceStatusTimer(context);

    _screenManager();

    _appFrame();

    _listener();

    widget.appState.items = this.items;

    Widget body;

    if (widget.appState.applicationStyle?.desktopIcon != null) {
      body = Container(
          decoration: BoxDecoration(
              image: !kIsWeb
                  ? DecorationImage(
                      image: FileImage(File(
                          '${widget.appState.dir}${widget.appState.applicationStyle?.desktopIcon}')),
                      fit: BoxFit.cover)
                  : DecorationImage(
                      image: widget.appState.files.containsKey(
                              widget.appState.applicationStyle?.desktopIcon)
                          ? MemoryImage(base64Decode(widget.appState.files[
                              widget.appState.applicationStyle?.desktopIcon]))
                          : null,
                      fit: BoxFit.cover,
                    )),
          child: getMenuWidget(context, widget.appState, hasMultipleGroups,
              _onPressed, menuMode));
    } else {
      body = getMenuWidget(
          context, widget.appState, hasMultipleGroups, _onPressed, menuMode);
    }

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        }
        return false;
      },
      child: BlocListener<ApiBloc, Response>(
        listener: (context, response) {
          if (response.request.requestType == RequestType.LOADING) {
            showProgress(context);
          }

          if (response.request.requestType != RequestType.LOADING) {
            hideProgress(context);
          }

          if (response.hasError) {
            handleError(response, context);
          }

          if (response.deviceStatusResponse != null &&
              response.deviceStatusResponse.layoutMode != null &&
              response.request.requestType == RequestType.DEVICE_STATUS) {
            this.setState(() {
              widget.appState.layoutMode =
                  response.deviceStatusResponse.layoutMode;
            });
          }

          if (response.request.requestType == RequestType.MENU) {
            setState(() {
              widget.appState.items = response.menu.entries;
              this.items = response.menu.entries;
            });
          }

          if (response.userData != null) {
            widget.appState.screenManager.onUserData(response.userData);
          }

          if (response.responseData.screenGeneric != null &&
              response.request.requestType == RequestType.OPEN_SCREEN) {
            Navigator.of(context).pushReplacementNamed(OpenScreenPage.route,
                arguments: ScreenArguments(
                  response: response,
                  menuComponentId:
                      (response.request as OpenScreen).action.componentId,
                  title: response.responseData.screenGeneric.screenTitle,
                  items: this.items,
                ));
          }
        },
        child: Scaffold(
            key: _scaffoldKey,
            appBar: widget.appState.appFrame.showScreenHeader
                ? AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    title: Text('Menu' +
                        (widget.appState.isOffline ? ' - Offline' : '')),
                    automaticallyImplyLeading: false,
                    actions: [
                      widget.appState.isOffline
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.appState.offline = false;
                                  SharedPrefProvider.of(context)
                                      .manager
                                      .setOffline(false);

                                  (sl<IOfflineDatabaseProvider>()
                                          as OfflineDatabase)
                                      .cleanupDatabase()
                                      .then((value) =>
                                          sl<IOfflineDatabaseProvider>()
                                              .syncOnline(context));

                                  BlocProvider.of<ApiBloc>(context)
                                      .add(Menu(widget.appState.clientId));
                                });
                              },
                              icon: FaIcon(FontAwesomeIcons.broadcastTower),
                            )
                          : Container(),
                      IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                        icon: FaIcon(FontAwesomeIcons.ellipsisV),
                      ),
                    ],
                  )
                : null,
            endDrawer: widget.appState.appFrame.showScreenHeader
                ? MenuDrawerWidget(
                    onPressed: _onPressed,
                    menuItems: this.items,
                    listMenuItems: true,
                    groupedMenuMode: groupedMenuMode,
                    appState: widget.appState,
                    currentTitle: title,
                  )
                : null,
            body: RefreshIndicator(
              onRefresh: () async {
                Menu menuRequest = Menu(widget.appState.clientId);

                BlocProvider.of<ApiBloc>(context).add(menuRequest);
              },
              child: FractionallySizedBox(
                  widthFactor: 1, heightFactor: 1, child: body),
            )),
      ),
    );
  }
}
