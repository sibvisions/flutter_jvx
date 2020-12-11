import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/core/models/api/request.dart';
import 'package:jvx_flutterclient/core/models/api/request/download.dart';
import 'package:jvx_flutterclient/core/models/api/request/navigation.dart';
import 'package:jvx_flutterclient/core/models/api/request/open_screen.dart';
import 'package:jvx_flutterclient/core/models/api/request/reload.dart';
import 'package:jvx_flutterclient/core/models/api/request/upload.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/models/api/response/device_status_response.dart';
import 'package:jvx_flutterclient/core/models/api/response/menu_item.dart';
import 'package:jvx_flutterclient/core/models/api/so_action.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:jvx_flutterclient/core/models/app/menu_arguments.dart';
import 'package:jvx_flutterclient/core/services/remote/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/core/ui/frames/app_frame.dart';
import 'package:jvx_flutterclient/core/ui/pages/menu_page.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_screen.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_screen_configuration.dart';
import 'package:jvx_flutterclient/core/ui/widgets/dialogs/upload_file_picker.dart';
import 'package:jvx_flutterclient/core/ui/widgets/menu/menu_drawer_widget.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/error_handling.dart';
import 'package:jvx_flutterclient/core/utils/app/get_menu_widget.dart';
import 'package:jvx_flutterclient/core/utils/app/listener/application_api.dart';

import '../../../../injection_container.dart';

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

  Orientation orientation;
  double width;
  double height;

  String title;

  GlobalKey screenGlobalKey;

  int currentIndex = 0;
  Response currentResponse;

  String get currentCompId {
    if (widget.appState.screenManager.screens != null &&
        widget.appState.screenManager.screens.isNotEmpty) {
      return widget.appState.screenManager.screens.keys
          .toList()[this.currentIndex];
    } else
      return null;
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
        debugLabel: widget.response.responseData.screenGeneric.componentId);

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
    if (widget.appState.screenManager != null &&
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
    if (widget.appState.screenManager != null &&
        widget.appState.screenManager.screens != null &&
        widget.appState.screenManager.screens.isNotEmpty) {
      widget.appState.screenManager.screens.forEach((_, screen) {
        screen.configuration.value = response;
      });
    }
  }

  /// Method for creating a bloc listener and all the logic for the screens
  Widget _blocListener() {
    return BlocListener<ApiBloc, Response>(
      listener: (BuildContext context, Response state) {
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

              if (widget.appState.screenManager.findScreen(
                      state.responseData.screenGeneric.componentId) ==
                  null) {
                widget.appState.screenManager.registerScreen(SoScreen(
                  configuration: SoScreenConfiguration(state,
                      screenTitle: state.responseData.screenGeneric.screenTitle,
                      componentId: state.responseData.screenGeneric.componentId,
                      withServer: true),
                ));
              }
            }

            if (state.request.requestType == RequestType.DEVICE_STATUS)
              _onDeviceStatusResponse(state.deviceStatusResponse);

            if (state.request.requestType == RequestType.PRESS_BUTTON)
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
      },
      child: WillPopScope(
        onWillPop: () async => _onWillPop(),
        child: openScreenBuilder(),
      ),
    );
  }

  MenuDrawerWidget _endDrawer() => widget.appState.appFrame.showScreenHeader
      ? MenuDrawerWidget(
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
                Navigation navigation = Navigation(
                    clientId: widget.appState.clientId,
                    componentId: this.currentCompId);

                Future.delayed(const Duration(milliseconds: 100), () {
                  BlocProvider.of<ApiBloc>(context).add(navigation);
                });
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
              SoScreen screen;

              if (this.currentCompId == null) {
                screen = SoScreen(
                  configuration: SoScreenConfiguration(this.currentResponse,
                      screenTitle: this
                              .currentResponse
                              .responseData
                              .screenGeneric
                              ?.screenTitle ??
                          this.title,
                      componentId: this
                              .currentResponse
                              .responseData
                              .screenGeneric
                              ?.componentId ??
                          widget
                              .response.responseData.screenGeneric.componentId,
                      withServer: true),
                );

                if (this.currentResponse.request.requestType !=
                        RequestType.NAVIGATION &&
                    this.currentResponse.request.requestType !=
                        RequestType.CLOSE_SCREEN &&
                    this.currentResponse.responseData.screenGeneric != null &&
                    this
                            .currentResponse
                            .responseData
                            .screenGeneric
                            .componentId ==
                        screen.configuration.componentId) {
                  widget.appState.screenManager.registerScreen(screen);
                }
              } else if (widget.appState.screenManager
                      .findScreen(widget.menuComponentId) !=
                  null) {
                screen = widget.appState.screenManager
                    .findScreen(widget.menuComponentId);
              } else if (widget.appState.screenManager
                      .findScreen(this.currentCompId) !=
                  null) {
                screen = widget.appState.screenManager
                    .findScreen(this.currentCompId);
              }

              _updateOpenScreens(this.currentResponse);

              if (this.currentResponse.responseData.screenGeneric != null) {
                this.currentIndex = widget.appState.screenManager.screens.keys
                    .toList()
                    .indexOf(this
                        .currentResponse
                        .responseData
                        .screenGeneric
                        .componentId);
              }

              if (screen.configuration.screenTitle != null &&
                  screen.configuration.screenTitle.isNotEmpty &&
                  screen.configuration.screenTitle != this.title) {
                this.title = screen.configuration.screenTitle;
              }

              Widget child;

              if (currentIndex >= 0) {
                child = IndexedStack(
                  children: widget.appState.screenManager.screens.values
                      .map((e) => e)
                      .toList(),
                  index: currentIndex,
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
    Navigation navigation = Navigation(
        clientId: widget.appState.clientId, componentId: this.currentCompId);

    BlocProvider.of<ApiBloc>(context).add(navigation);

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
      widget.appState.screenManager
          .removeScreen(response.closeScreenAction.componentId);
    } else {
      widget.appState.screenManager.removeScreen(this.currentCompId);
    }

    if (widget.appState.screenManager.screens != null &&
        widget.appState.screenManager.screens.isEmpty) {
      // When no more screens exist return to menu page
      Navigator.of(context).pushReplacementNamed(MenuPage.route,
          arguments: MenuArguments(widget.appState.items, true));
    } else if (this.currentIndex > 0) {
      this.currentIndex = this.currentIndex - 1;
    }
  }
}
