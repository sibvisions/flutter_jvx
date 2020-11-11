import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/core/models/api/request/open_screen.dart';
import 'package:jvx_flutterclient/core/models/api/so_action.dart';
import 'package:jvx_flutterclient/core/ui/screen/i_screen.dart';

import '../../../models/api/request.dart';
import '../../../models/api/request/device_status.dart';
import '../../../models/api/request/download.dart';
import '../../../models/api/request/navigation.dart';
import '../../../models/api/request/upload.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/menu_item.dart';
import '../../../models/app/app_state.dart';
import '../../../models/app/menu_arguments.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../screen/component_screen_widget.dart';
import '../../screen/so_component_creator.dart';
import '../../screen/so_screen.dart';
import '../dialogs/upload_file_picker.dart';
import '../menu/menu_drawer_widget.dart';

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
  Orientation lastOrientation;
  double width;
  double height;
  RestartableTimer _deviceStatusTimer;
  String rawComponentId;
  String title;
  bool closeCurrentScreen;

  void _firePreviewerListener() {
    // if (widget.appState.appListener != null)
    //   widget.appState.appListener.fireOnUpdateListener(ApplicationApi(context));
  }

  void _createDeviceStatusTimer() {
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
      //   _deviceStatusTimer =
      //       RestartableTimer(const Duration(milliseconds: 50), () {
      //     DeviceStatus status = DeviceStatus(
      //         screenSize: MediaQuery.of(context).size,
      //         timeZoneCode: "",
      //         langCode: "");
      //     BlocProvider.of<ApiBloc>(context).add(status);
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

  _blocListener() => BlocListener<ApiBloc, Response>(
        listener: (BuildContext context, Response state) {
          if (state.request.requestType != RequestType.LOADING &&
              state.request.requestType != RequestType.DEVICE_STATUS) {
            if (state.request.requestType == RequestType.MENU) {
              widget.appState.items = state.menu.entries;
            }

            if (state.request.requestType == RequestType.CLOSE_SCREEN) {
              Navigator.of(context).pushReplacementNamed('/menu',
                  arguments: MenuArguments(widget.appState.items, true));
            } else {
              if (isScreenRequest(state.request.requestType)) {
                if (state.responseData.screenGeneric != null &&
                    !state.responseData.screenGeneric.update) {
                  setState(() {
                    title = state.responseData.screenGeneric.screenTitle;
                  });
                }

                setState(() {
                  widget.response.responseData = state.responseData;
                  widget.response.request = state.request;

                  if (state.closeScreenAction != null) {
                    this.closeCurrentScreen = true;
                  } else {
                    this.closeCurrentScreen = false;
                  }
                });

                _checkForButtonAction(state);

                if (state.request.requestType == RequestType.OPEN_SCREEN) {
                  if (mounted &&
                      _scaffoldKey.currentState != null &&
                      _scaffoldKey.currentState.isEndDrawerOpen)
                    SchedulerBinding.instance.addPostFrameCallback(
                        (_) => Navigator.of(context).pop());

                  rawComponentId =
                      state.responseData?.screenGeneric?.componentId;
                }

                if (state.responseData.screenGeneric != null &&
                    !state.responseData.screenGeneric.update) {
                  rawComponentId = state.responseData.screenGeneric.componentId;
                }

                if (state.request.requestType == RequestType.NAVIGATION &&
                    state.responseData.screenGeneric == null) {
                  Navigator.of(context).pushReplacementNamed('/menu',
                      arguments: MenuArguments(widget.appState.items, true));
                }
              }
            }
          } else if (state.request.requestType == RequestType.DEVICE_STATUS) {
            setState(() {
              widget.appState?.layoutMode =
                  state.deviceStatusResponse?.layoutMode;
            });
          }
        },
        child: WillPopScope(
            onWillPop: () async => _onWillPop(),
            child: Scaffold(
                endDrawer: _endDrawer(),
                key: _scaffoldKey,
                appBar: _appBar(this.title),
                body: Builder(builder: (BuildContext context) {
                  SoScreen screen = SoScreen(
                    componentId: rawComponentId,
                    child: ComponentScreenWidget(
                      closeCurrentScreen: closeCurrentScreen,
                      componentCreator: SoComponentCreator(context),
                      request: widget.response.request,
                      responseData: widget.response.responseData,
                    ),
                  );

                  screen.update(
                      widget.response.request, widget.response.responseData);

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
                                    image: widget.appState.files.containsKey(
                                            widget.appState.applicationStyle
                                                .desktopIcon)
                                        ? MemoryImage(base64Decode(
                                            widget.appState.files[widget
                                                .appState
                                                .applicationStyle
                                                .desktopIcon]))
                                        : null,
                                    fit: BoxFit.cover,
                                  )),
                        child: screen));

                    return widget.appState.appFrame.getWidget();
                  } else if (widget.appState.applicationStyle != null &&
                      widget.appState.applicationStyle?.desktopColor != null) {
                    widget.appState.appFrame.setScreen(Container(
                        decoration: BoxDecoration(
                            color:
                                widget.appState.applicationStyle?.desktopColor),
                        child: screen));

                    return widget.appState.appFrame.getWidget();
                  } else {
                    widget.appState.appFrame.setScreen(screen);
                    return widget.appState.appFrame.getWidget();
                  }
                }))),
      );

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
                    componentId: rawComponentId);

                Future.delayed(const Duration(milliseconds: 100), () {
                  BlocProvider.of<ApiBloc>(context).add(navigation);
                });
              },
            ),
            title: Text(title),
          )
        : null;
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

  _onWillPop() async {
    Navigation navigation = Navigation(
        clientId: widget.appState.clientId, componentId: rawComponentId);

    BlocProvider.of<ApiBloc>(context).add(navigation);

    bool close = false;

    await for (Response res in BlocProvider.of<ApiBloc>(context)) {
      if (res.request.requestType == RequestType.NAVIGATION) {
        close = true;
      }
    }

    return close;
  }

  _checkForButtonAction(Response state) {
    if (state.request.requestType == RequestType.PRESS_BUTTON) {
      if (state.downloadAction != null) {
        Download download = Download(
            applicationImages: false,
            libraryImages: false,
            clientId: widget.appState.clientId,
            fileId: state.downloadAction.fileId,
            name: 'file',
            requestType: RequestType.DOWNLOAD);

        BlocProvider.of<ApiBloc>(context).add(download);
      } else if (state.uploadAction != null) {
        openFilePicker(context, widget.appState).then((file) {
          if (file != null) {
            Upload upload = Upload(
                clientId: widget.appState.clientId,
                file: file,
                fileId: state.uploadAction.fileId,
                requestType: RequestType.UPLOAD);

            BlocProvider.of<ApiBloc>(context).add(upload);
          }
        });
      } else if (state.closeScreenAction != null) {
        if (state.responseData.screenGeneric == null)
          Navigator.of(context).pushReplacementNamed('/menu',
              arguments: MenuArguments(widget.appState.items, true));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    this.title = widget.title;

    rawComponentId = widget.response.responseData.screenGeneric.componentId;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    _firePreviewerListener();

    _createDeviceStatusTimer();

    return _blocListener();
  }
}
