import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/features/custom_screen/ui/screen/custom_screen.dart';

import '../../../../injection_container.dart';
import '../../../models/api/request.dart';
import '../../../models/api/request/download.dart';
import '../../../models/api/request/navigation.dart';
import '../../../models/api/request/open_screen.dart';
import '../../../models/api/request/reload.dart';
import '../../../models/api/request/upload.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/device_status_response.dart';
import '../../../models/api/response/menu_item.dart';
import '../../../models/api/so_action.dart';
import '../../../models/app/app_state.dart';
import '../../../models/app/menu_arguments.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/get_menu_widget.dart';
import '../../../utils/app/listener/application_api.dart';
import '../../frames/app_frame.dart';
import '../../pages/menu_page.dart';
import '../../screen/screen_manager.dart';
import '../../screen/so_screen.dart';
import '../../screen/so_screen_configuration.dart';
import '../dialogs/upload_file_picker.dart';
import '../menu/menu_drawer_widget.dart';
import '../util/error_handling.dart';
import '../util/restart_widget.dart';
import '../util/shared_pref_provider.dart';

class OpenScreenPageWidget extends StatefulWidget {
  final String title;
  final Response response;
  final String menuComponentId;
  final String templateName;
  final List<MenuItem> items;
  final AppState appState;

  const OpenScreenPageWidget(
      {Key key,
      this.title,
      this.response,
      this.menuComponentId,
      this.templateName,
      this.items,
      this.appState})
      : super(key: key);

  @override
  _OpenScreenPageWidgetState createState() => _OpenScreenPageWidgetState();
}

class _OpenScreenPageWidgetState extends State<OpenScreenPageWidget>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ScreenManager _openScreenManager = ScreenManager();

  Orientation orientation;
  double width;
  double height;

  String title;

  GlobalKey screenGlobalKey;

  int currentIndex = 0;
  Response currentResponse;

  String get currentCompId {
    try {
      if (_openScreenManager.screens != null &&
          _openScreenManager.screens.isNotEmpty) {
        return _openScreenManager.screens.keys.toList()[this.currentIndex];
      } else
        return null;
    } catch (e) {
      return null;
    }
  }

  String get menuMode {
    if (widget.appState.applicationStyle != null &&
        widget.appState.applicationStyle?.menuMode != null)
      return widget.appState.applicationStyle?.menuMode;
    else
      return 'grid';
  }

  @override
  Widget build(BuildContext context) {
    return _blocListener();
  }

  @override
  void initState() {
    if (widget.appState.appListener != null) {
      widget.appState.appListener
          .fireAfterStartupListener(ApplicationApi(context));
    }

    super.initState();

    this.currentResponse = widget.response;

    this.title = widget.title;

    _appFrame();

    this.screenGlobalKey = GlobalKey<SoScreenState>(
        debugLabel: widget.response?.responseData?.screenGeneric?.componentId ??
            widget.menuComponentId);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _appFrame() {
    if (widget.appState.appFrame is AppFrame) {
      widget.appState.appFrame = AppFrame(context);
    }

    getMenuWidget(
        context, widget.appState, hasMultipleGroups(), _onPressed, menuMode);
  }

  _onPressed(MenuItem menuItem) {
    if (widget.appState.screenManager.screens != null &&
        widget.appState.screenManager.screens.isNotEmpty &&
        !widget.appState.screenManager
            .getScreen(menuItem.componentId)
            .configuration
            .withServer) {
      SoScreen screen =
          widget.appState.screenManager.getScreen(menuItem.componentId);

      widget.appState.appFrame.setScreen(screen);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => Theme(
                data: Theme.of(context),
                child: BlocProvider<ApiBloc>(
                    create: (_) => sl<ApiBloc>(),
                    child: widget.appState.appFrame.getWidget()),
              )));
    } else {
      SoAction action =
          SoAction(componentId: menuItem.componentId, label: menuItem.text);

      this.title = action.label != null ? action.label : this.title;

      OpenScreen openScreen = OpenScreen(
        action: action,
        clientId: widget.appState.clientId,
        manualClose: false,
        requestType: RequestType.OPEN_SCREEN,
      );

      BlocProvider.of<ApiBloc>(context).add(openScreen);
    }
  }

  /// Method for updating listener for VisionXPreviewer
  void _firePreviewerListener() {}

  /// Method for updating screens with newest response
  void _updateOpenScreens(Response response) {
    if (_openScreenManager != null &&
        _openScreenManager.screens != null &&
        _openScreenManager.screens.isNotEmpty) {
      _openScreenManager.screens.forEach((_, screen) {
        screen.configuration.value = response;
      });
    }
  }

  /// Method for creating a bloc listener and all the logic for the screens
  Widget _blocListener() {
    return BlocListener<ApiBloc, Response>(
      listener: (BuildContext context, Response state) {
        if (state != null) {
          // Checking for error
          if (state.hasError) {
            handleError(state, context);
          }

          if (state.request.requestType != RequestType.LOADING) {
            // Updating menu
            if (state.request.requestType == RequestType.MENU)
              _onMenuResponse(state.menu.entries);

            if (state.request.requestType == RequestType.CLOSE_SCREEN) {
              _onCloseScreen(state);
            } else if (isScreenRequest(state.request.requestType)) {
              // Update response
              setState(() {
                this.currentResponse = state;
              });

              if (state.responseData.screenGeneric != null &&
                  state.responseData.screenGeneric.screenTitle != null) {
                setState(() {
                  title = state.responseData.screenGeneric.screenTitle;
                });

                if (_openScreenManager.findScreen(
                        state.responseData.screenGeneric.componentId) ==
                    null) {
                  _openScreenManager.registerScreen(SoScreen(
                    configuration: SoScreenConfiguration(state,
                        screenTitle:
                            state.responseData.screenGeneric.screenTitle,
                        componentId:
                            state.responseData.screenGeneric.componentId,
                        screenComponentId: widget.menuComponentId,
                        withServer: true),
                  ));
                }
              }

              if (state.request.requestType == RequestType.DEVICE_STATUS)
                _onDeviceStatusResponse(state.deviceStatusResponse);

              _onPressButtonRequest(state);

              if (state.request.requestType == RequestType.OPEN_SCREEN) {
                _onOpenScreen(state);
              }

              if (state.request.requestType == RequestType.NAVIGATION &&
                  state.responseData.screenGeneric == null) {
                _onCloseScreen(state);
              }
            }
          }
        }
      },
      child: WillPopScope(
        onWillPop: () async => _onWillPop(),
        child: openScreenBuilder(),
      ),
    );
  }

  MenuDrawerWidget _endDrawer() => widget.appState.appFrame.showScreenHeader
      ? MenuDrawerWidget(
          onPressed: _onPressed,
          appState: widget.appState,
          menuItems: widget.items,
          listMenuItems: true,
          currentTitle: widget.title,
          groupedMenuMode:
              (widget.appState.applicationStyle?.menuMode == 'grid_grouped' ||
                      widget.appState.applicationStyle?.menuMode == 'list') &
                  hasMultipleGroups(),
        )
      : null;

  bool hasMultipleGroups() {
    int groupCount = 0;
    String lastGroup = "";
    if (widget.items != null) {
      widget.items?.forEach((m) {
        if (m.group != lastGroup) {
          groupCount++;
          lastGroup = m.group;
        }
      });
    }
    return (groupCount > 1);
  }

  AppBar _appBar(String title) {
    return widget.appState.appFrame.showScreenHeader
        ? AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            actions: <Widget>[
              IconButton(
                icon: FaIcon(FontAwesomeIcons.ellipsisV),
                onPressed: () => _scaffoldKey.currentState.openEndDrawer(),
              )
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (_openScreenManager.screens.values
                        .toList()[currentIndex]
                        .configuration
                        ?.onBack !=
                    null) {
                  if (_openScreenManager.screens[currentIndex].configuration
                      .onBack()) {
                    Navigation navigation = Navigation(
                        clientId: widget.appState.clientId,
                        componentId: this.currentCompId);

                    BlocProvider.of<ApiBloc>(context).add(navigation);
                  }
                } else {
                  Navigation navigation = Navigation(
                      clientId: widget.appState.clientId,
                      componentId: this.currentCompId);

                  Future.delayed(const Duration(milliseconds: 100), () {
                    BlocProvider.of<ApiBloc>(context).add(navigation);
                  });
                }
              },
            ),
            title: Text(title ?? ''),
          )
        : null;
  }

  Widget openScreenBuilder() => Scaffold(
        key: _scaffoldKey,
        appBar: _appBar(this.title),
        endDrawer: _endDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            Reload reload = Reload(
                clientId: widget.appState.clientId,
                requestType: RequestType.RELOAD);

            BlocProvider.of<ApiBloc>(context).add(reload);
          },
          child: Builder(
            builder: (BuildContext context) {
              SoScreen screen = widget.appState.screenManager
                  .findScreen(widget.menuComponentId);

              if (screen != null &&
                  !_openScreenManager.screens
                      .containsKey(widget.menuComponentId)) {
                // If custom screen exists and is not yet added to openscreen stack
                _openScreenManager.registerScreen(screen);
                screen.configuration.value = this.currentResponse;
              } else if (screen != null &&
                  _openScreenManager.screens
                      .containsKey(widget.menuComponentId)) {
                // If custom screen exists and is added to openscreen stack
                screen.configuration.value = this.currentResponse;
              } else if (screen == null &&
                  (_openScreenManager.screens
                          .containsKey(widget.menuComponentId) ||
                      _openScreenManager.screens
                          .containsKey(this.currentCompId))) {
                // If custom screen is null
                screen =
                    _openScreenManager.findScreen(widget.menuComponentId) ??
                        _openScreenManager.findScreen(this.currentCompId);
                screen.configuration.value = this.currentResponse;
              } else {
                // If both custom screen and normal screen is null
                screen = SoScreen(
                  configuration: SoScreenConfiguration(this.currentResponse,
                      screenTitle: this
                              .currentResponse
                              ?.responseData
                              ?.screenGeneric
                              ?.screenTitle ??
                          this.title,
                      componentId: this
                              .currentResponse
                              ?.responseData
                              ?.screenGeneric
                              ?.componentId ??
                          widget.response?.responseData?.screenGeneric
                              ?.componentId ??
                          widget.menuComponentId,
                      screenComponentId: widget.menuComponentId,
                      withServer: true),
                );

                if (this.currentResponse?.request?.requestType !=
                        RequestType.NAVIGATION &&
                    this.currentResponse?.request?.requestType !=
                        RequestType.CLOSE_SCREEN &&
                    this.currentResponse?.responseData?.screenGeneric != null &&
                    this
                            .currentResponse
                            .responseData
                            .screenGeneric
                            .componentId ==
                        screen.configuration.componentId) {
                  _openScreenManager.registerScreen(screen);
                }
              }

              if (screen.configuration.screenTitle != null &&
                  screen.configuration.screenTitle.isNotEmpty &&
                  screen.configuration.screenTitle != this.title) {
                this.title = screen.configuration.screenTitle;
              }
              _updateOpenScreens(this.currentResponse);

              if (this.currentResponse?.responseData?.screenGeneric != null) {
                this.currentIndex = _openScreenManager.screens.keys
                    .toList()
                    .indexOf(this
                        .currentResponse
                        .responseData
                        .screenGeneric
                        .componentId);

                if (this.currentIndex < 0) {
                  this.currentIndex = _openScreenManager.screens.keys
                      .toList()
                      .indexOf(widget.menuComponentId);
                }
              }

              Widget child;

              if (currentIndex >= 0) {
                child = IndexedStack(
                  children: _openScreenManager.screens.values.toList(),
                  index: currentIndex >= 0 ? currentIndex : 0,
                  key: this.screenGlobalKey,
                );
              }

              if (widget.appState.applicationStyle != null &&
                  widget.appState.applicationStyle?.desktopIcon != null) {
                widget.appState.appFrame.setScreen(Container(
                    decoration: BoxDecoration(
                        color: (widget.appState.applicationStyle != null &&
                                widget.appState.applicationStyle
                                        ?.desktopColor !=
                                    null)
                            ? widget.appState.applicationStyle?.desktopColor
                            : null,
                        image: !kIsWeb
                            ? DecorationImage(
                                image: FileImage(File(
                                    '${widget.appState.dir}${widget.appState.applicationStyle?.desktopIcon}')),
                                fit: BoxFit.cover)
                            : DecorationImage(
                                image: widget.appState.files.containsKey(widget
                                        .appState.applicationStyle.desktopIcon)
                                    ? MemoryImage(base64Decode(
                                        widget.appState.files[widget.appState
                                            .applicationStyle.desktopIcon]))
                                    : null,
                                fit: BoxFit.cover,
                              )),
                    child: child));

                return widget.appState.appFrame.getWidget();
              } else if (widget.appState.applicationStyle != null &&
                  widget.appState.applicationStyle?.desktopColor != null) {
                widget.appState.appFrame.setScreen(Container(
                    decoration: BoxDecoration(
                        color: widget.appState.applicationStyle?.desktopColor),
                    child: child));

                return widget.appState.appFrame.getWidget();
              } else {
                widget.appState.appFrame.setScreen(child);
                return widget.appState.appFrame.getWidget();
              }
            },
          ),
        ),
      );

  Future<bool> _onWillPop() async {
    if (_openScreenManager.screens[currentIndex] is CustomScreen &&
        _openScreenManager.screens[currentIndex].configuration?.onBack !=
            null) {
      if (_openScreenManager.screens[currentIndex].configuration.onBack()) {
        Navigation navigation = Navigation(
            clientId: widget.appState.clientId,
            componentId: this.currentCompId);

        BlocProvider.of<ApiBloc>(context).add(navigation);
      }
    } else {
      Navigation navigation = Navigation(
          clientId: widget.appState.clientId, componentId: this.currentCompId);

      BlocProvider.of<ApiBloc>(context).add(navigation);
    }

    return false;
  }

  void _onOpenScreen(Response response) {}

  void _onMenuResponse(List<MenuItem> entries) =>
      widget.appState.items = entries;

  void _onDeviceStatusResponse(DeviceStatusResponse deviceStatus) =>
      setState(() => widget.appState.layoutMode = deviceStatus.layoutMode);

  void _onPressButtonRequest(Response response) {
    if (response.downloadAction != null) {
      Download download = Download(
          applicationImages: false,
          libraryImages: false,
          clientId: widget.appState.clientId,
          fileId: response.downloadAction.fileId,
          name: 'file',
          requestType: RequestType.DOWNLOAD);

      BlocProvider.of<ApiBloc>(context).add(download);
    } else if (response.uploadAction != null) {
      openFilePicker(context, widget.appState).then((file) {
        if (file != null) {
          Upload upload = Upload(
              clientId: widget.appState.clientId,
              file: file,
              fileId: response.uploadAction.fileId,
              requestType: RequestType.UPLOAD);

          BlocProvider.of<ApiBloc>(context).add(upload);
        }
      });
    } else if (response.closeScreenAction != null) _onCloseScreen(response);
  }

  void _onCloseScreen(Response response) {
    // Removing current screen
    if (response.closeScreenAction != null &&
        response.closeScreenAction.componentId != null) {
      _openScreenManager.removeScreen(response.closeScreenAction.componentId);
    } else {
      _openScreenManager.removeScreen(this.currentCompId);
    }

    if (_openScreenManager.screens != null &&
        _openScreenManager.screens.isEmpty &&
        response.responseData.screenGeneric == null) {
      // When no more screens exist return to menu page
      Navigator.of(context).pushReplacementNamed(MenuPage.route,
          arguments: MenuArguments(widget.appState.items, true));
    } else if (this.currentIndex > 0) {
      this.currentIndex = this.currentIndex - 1;
    }
  }
}
