import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/api/request.dart';
import '../../../models/api/request/device_status.dart';
import '../../../models/api/request/open_screen.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/menu_item.dart';
import '../../../models/api/so_action.dart';
import '../../../models/app/app_state.dart';
import '../../../models/app/screen_arguments.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/listener/application_api.dart';
import '../../frames/app_frame.dart';
import '../../screen/i_screen.dart';
import '../../screen/so_menu_manager.dart';
import '../dialogs/dialogs.dart';
import '../menu/menu_drawer_widget.dart';
import '../menu/menu_empty.dart';
import '../menu/menu_grid_view.dart';
import '../menu/menu_list_widget.dart';
import '../menu/menu_swiper_right.dart';
import '../menu/menu_tabs_widget.dart';
import '../util/error_handling.dart';
import '../web/web_menu_list_widget.dart';

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
            label: widget.appState.appName + ' - ' + widget.appState.username));

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
          '/screen',
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
      if (_deviceStatusTimer == null) {
        _deviceStatusTimer = RestartableTimer(const Duration(seconds: 50), () {
          DeviceStatus deviceStatus = DeviceStatus(
            screenSize: MediaQuery.of(context).size,
            timeZoneCode: '',
            langCode: '',
          );

          BlocProvider.of<ApiBloc>(context).add(deviceStatus);
          lastOrientation = MediaQuery.of(context).orientation;
          width = MediaQuery.of(context).size.width;
          height = MediaQuery.of(context).size.height;

          _deviceStatusTimer.cancel();
          _deviceStatusTimer = null;
        });
      } else {
        _deviceStatusTimer.reset();
      }
    }
  }

  _screenManager() {
    if (widget.appState.screenManager != null) {
      SoMenuManager menuManager = SoMenuManager(this.items);
      widget.appState.screenManager.onMenu(menuManager);
      this.items = menuManager.menuItems;
    }
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
    if (widget.appState.screenManager != null &&
        !widget.appState.screenManager
            .getScreen(menuItem.componentId, templateName: menuItem.text)
            .withServer()) {
      IScreen screen = widget.appState.screenManager
          .getScreen(menuItem.componentId, templateName: menuItem.text);

      widget.appState.appFrame.setScreen(screen);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => widget.appState.appFrame.getWidget()));
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

  Widget _getMenuWidget(BuildContext context) {
    widget.appState.appFrame.screen = null;

    if (!widget.appState.appFrame.showScreenHeader) {
      widget.appState.appFrame.setMenu(WebMenuListWidget(
        menuItems: this.widget.menuItems,
        groupedMenuMode: hasMultipleGroups,
        onPressed: _onPressed,
        appState: widget.appState,
      ));
    } else {
      switch (menuMode) {
        case 'grid':
          widget.appState.appFrame.setMenu(MenuGridView(
            items: this.widget.menuItems,
            groupedMenuMode: false,
            onPressed: _onPressed,
            appState: widget.appState,
          ));
          break;
        case 'list':
          widget.appState.appFrame.setMenu(MenuListWidget(
            menuItems: this.widget.menuItems,
            groupedMenuMode: hasMultipleGroups,
            onPressed: _onPressed,
            appState: widget.appState,
          ));
          break;
        case 'drawer':
          widget.appState.appFrame.setMenu(MenuEmpty());
          break;
        case 'grid_grouped':
          widget.appState.appFrame.setMenu(MenuGridView(
              items: this.widget.menuItems,
              groupedMenuMode: hasMultipleGroups,
              onPressed: _onPressed,
              appState: widget.appState));
          break;
        case 'swiper':
          widget.appState.appFrame.setMenu(MenuSwiperWidget(
              items: this.widget.menuItems,
              groupedMenuMode: hasMultipleGroups,
              onPressed: _onPressed,
              appState: widget.appState));
          break;
        case 'tabs':
          widget.appState.appFrame.setMenu(MenuTabsWidget(
              items: this.widget.menuItems,
              groupedMenuMode: hasMultipleGroups,
              onPressed: _onPressed,
              appState: widget.appState));
          break;
        default:
          widget.appState.appFrame.setMenu(MenuGridView(
              items: this.widget.menuItems,
              groupedMenuMode: hasMultipleGroups,
              onPressed: _onPressed,
              appState: widget.appState));
          break;
      }
    }
    return widget.appState.appFrame.getWidget();
  }

  @override
  void initState() {
    super.initState();
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
          child: _getMenuWidget(context));
    } else {
      body = _getMenuWidget(context);
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
            Navigator.of(context).pushReplacementNamed('/screen',
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
                    title: Text('Menu'),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                        icon: FaIcon(FontAwesomeIcons.ellipsisV),
                      )
                    ],
                  )
                : null,
            endDrawer: widget.appState.appFrame.showScreenHeader
                ? MenuDrawerWidget(
                    menuItems: this.items,
                    listMenuItems: true,
                    groupedMenuMode: groupedMenuMode,
                    appState: widget.appState,
                    currentTitle: title,
                  )
                : null,
            body: FractionallySizedBox(
                widthFactor: 1, heightFactor: 1, child: body)),
      ),
    );
  }
}
