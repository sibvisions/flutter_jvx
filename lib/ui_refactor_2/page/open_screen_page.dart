import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/component_screen_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/so_component_creator.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/so_screen.dart';

import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../model/api/request/device_Status.dart';
import '../../model/api/request/download.dart';
import '../../model/api/request/navigation.dart';
import '../../model/api/request/request.dart';
import '../../model/api/request/upload.dart';
import '../../model/api/response/response.dart';
import '../../model/api/response/response_data.dart';
import '../../model/menu_item.dart';
import '../../ui/page/menu_arguments.dart';
import '../../ui/widgets/menu_drawer_widget.dart';
import '../../utils/application_api.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/uidata.dart';
import '../widgets/dialogs/upload_file_picker.dart';

class OpenScreenPage extends StatefulWidget {
  final String title;
  final Key componentId;
  final List<MenuItem> items;
  final ResponseData responseData;
  final Request request;
  final String menuComponentId;
  final String templateName;

  const OpenScreenPage(
      {Key key,
      this.title,
      this.componentId,
      this.items,
      this.responseData,
      this.request,
      this.menuComponentId,
      this.templateName})
      : super(key: key);

  @override
  _OpenScreenPageState createState() => _OpenScreenPageState();
}

class _OpenScreenPageState extends State<OpenScreenPage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Orientation lastOrientation;
  double width;
  double height;
  RestartableTimer _deviceStatusTimer;
  String rawComponentId;
  String title;

  bool closeCurrentScreen = false;
  Request currentRequest;
  ResponseData currentResponseData;

  String _getRawCompId() =>
      widget.componentId.toString().replaceAll("[<'", '').replaceAll("'>]", '');

  void _firePreviewerListener() {
    // if (globals.appListener != null)
    //   globals.appListener.fireOnUpdateListener(ApplicationApi(context));
  }

  void _createDeviceStatusTimer() {
    if (lastOrientation == null) {
      lastOrientation = MediaQuery.of(context).orientation;
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    } else if (lastOrientation != MediaQuery.of(context).orientation ||
        width != MediaQuery.of(context).size.width ||
        height != MediaQuery.of(context).size.height) {
      if (_deviceStatusTimer == null) {
        _deviceStatusTimer =
            RestartableTimer(const Duration(milliseconds: 50), () {
          DeviceStatus status = DeviceStatus(
              screenSize: MediaQuery.of(context).size,
              timeZoneCode: "",
              langCode: "");
          BlocProvider.of<ApiBloc>(context).dispatch(status);
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

  _blocListener() => errorAndLoadingListener(BlocListener<ApiBloc, Response>(
        listener: (BuildContext context, Response state) {
          setState(() {
            if (state.request != null) this.currentRequest = state.request;
            if (state.responseData != null)
              this.currentResponseData = state.responseData;
            if (state.closeScreenAction != null) {
              this.closeCurrentScreen = true;
            } else {
              this.closeCurrentScreen = false;
            }
          });

          if (state.requestType == RequestType.MENU) {
            globals.items = state.menu.items;
          }

          if (state.requestType == RequestType.CLOSE_SCREEN) {
            Navigator.of(context).pushReplacementNamed('/menu',
                arguments: MenuArguments(globals.items, true));
          } else {
            if (isScreenRequest(state.requestType) && !state.loading) {
              if (state.responseData.screenGeneric != null &&
                  !state.responseData.screenGeneric.update) {
                setState(() {
                  title = state.responseData.screenGeneric.screenTitle;
                });
              }

              _checkForButtonAction(state);

              if (state.requestType == RequestType.OPEN_SCREEN) {
                if (mounted &&
                    _scaffoldKey.currentState != null &&
                    _scaffoldKey.currentState.isEndDrawerOpen)
                  SchedulerBinding.instance
                      .addPostFrameCallback((_) => Navigator.of(context).pop());

                rawComponentId = state.responseData?.screenGeneric?.componentId;
              }

              if (state.responseData.screenGeneric != null &&
                  !state.responseData.screenGeneric.update) {
                rawComponentId = state.responseData.screenGeneric.componentId;
              }

              if (state.requestType == RequestType.NAVIGATION &&
                  state.responseData.screenGeneric == null) {
                Navigator.of(context).pushReplacementNamed('/menu',
                    arguments: MenuArguments(globals.items, true));
              }
            }
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
                    componentId: _getRawCompId(),
                    child: ComponentScreenWidget(
                      closeCurrentScreen: closeCurrentScreen,
                      componentCreator: SoComponentCreator(this.context),
                      request: this.currentRequest,
                      responseData: this.currentResponseData,
                    ),
                  );

                  if (globals.applicationStyle != null &&
                      globals.applicationStyle?.desktopIcon != null) {
                    globals.appFrame.setScreen(Container(
                        decoration: BoxDecoration(
                            color: (globals.applicationStyle != null &&
                                    globals.applicationStyle.desktopColor !=
                                        null)
                                ? globals.applicationStyle.desktopColor
                                : null,
                            image: !kIsWeb
                                ? DecorationImage(
                                    image: FileImage(File(
                                        '${globals.dir}${globals.applicationStyle.desktopIcon}')),
                                    fit: BoxFit.cover)
                                : DecorationImage(
                                    image: globals.files.containsKey(globals
                                            .applicationStyle.desktopIcon)
                                        ? MemoryImage(base64Decode(
                                            globals.files[globals
                                                .applicationStyle.desktopIcon]))
                                        : null,
                                    fit: BoxFit.cover,
                                  )),
                        child: screen));

                    return globals.appFrame.getWidget();
                  } else if (globals.applicationStyle != null &&
                      globals.applicationStyle?.desktopColor != null) {
                    globals.appFrame.setScreen(Container(
                        decoration: BoxDecoration(
                            color: globals.applicationStyle.desktopColor),
                        child: screen));

                    return globals.appFrame.getWidget();
                  } else {
                    globals.appFrame.setScreen(screen);
                    return globals.appFrame.getWidget();
                  }
                }))),
      ));

  AppBar _appBar(String title) {
    return globals.appFrame.showScreenHeader
        ? AppBar(
            backgroundColor: UIData.ui_kit_color_2,
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
                    clientId: globals.clientId, componentId: _getRawCompId());

                Future.delayed(const Duration(milliseconds: 100), () {
                  BlocProvider.of<ApiBloc>(context).dispatch(navigation);
                });
              },
            ),
            title: Text(title),
          )
        : null;
  }

  MenuDrawerWidget _endDrawer() => globals.appFrame.showScreenHeader
      ? MenuDrawerWidget(
          menuItems: widget.items,
          listMenuItems: true,
          currentTitle: widget.title,
          groupedMenuMode:
              (globals.applicationStyle?.menuMode == 'grid_grouped' ||
                      globals.applicationStyle?.menuMode == 'list') &
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
    Navigation navigation =
        Navigation(clientId: globals.clientId, componentId: _getRawCompId());

    BlocProvider.of<ApiBloc>(context).dispatch(navigation);

    bool close = false;

    await for (Response res in BlocProvider.of<ApiBloc>(context).state) {
      if (res.requestType == RequestType.NAVIGATION) {
        close = true;
      }
    }

    return close;
  }

  _checkForButtonAction(Response state) {
    if (state.requestType == RequestType.PRESS_BUTTON) {
      if (state.downloadAction != null) {
        Download download = Download(
            applicationImages: false,
            libraryImages: false,
            clientId: globals.clientId,
            fileId: state.downloadAction.fileId,
            name: 'file',
            requestType: RequestType.DOWNLOAD);

        BlocProvider.of<ApiBloc>(context).dispatch(download);
      } else if (state.uploadAction != null) {
        openFilePicker(context).then((file) {
          if (file != null) {
            Upload upload = Upload(
                clientId: globals.clientId,
                file: file,
                fileId: state.uploadAction.fileId,
                requestType: RequestType.UPLOAD);

            BlocProvider.of<ApiBloc>(context).dispatch(upload);
          }
        });
      } else if (state.closeScreenAction != null) {
        if (state.responseData.screenGeneric == null)
          Navigator.of(context).pushReplacementNamed('/menu',
              arguments: MenuArguments(globals.items, true));
      }
    }
  }

  @override
  void initState() {
    globals.currentTempalteName = null;

    super.initState();

    this.title = widget.title;
    this.currentRequest = widget.request;
    this.currentResponseData = widget.responseData;

    rawComponentId = _getRawCompId();
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
