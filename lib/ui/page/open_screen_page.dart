import 'dart:io';
import 'dart:convert' as utf8;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jvx_flutterclient/ui/page/menu_page.dart';
import 'package:jvx_flutterclient/ui/tools/restart.dart';
import 'package:jvx_flutterclient/ui/widgets/common_dialogs.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/component_screen_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/i_screen.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/screen_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/so_component_creator.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/so_screen.dart';
import 'package:jvx_flutterclient/utils/application_api.dart';
import 'package:async/async.dart';

import '../../utils/text_utils.dart';
import '../../model/api/response/response_data.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../model/api/request/device_Status.dart';
import '../../model/api/request/download.dart';
import '../../model/api/request/navigation.dart';
import '../../model/api/request/request.dart';
import '../../model/api/request/upload.dart';
import '../../model/api/response/response.dart';
import '../../model/menu_item.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/translations.dart';
import '../../utils/uidata.dart';
import '../../ui/widgets/menu_drawer_widget.dart';
import 'menu_arguments.dart';

class OpenScreenPage extends StatefulWidget {
  final String title;
  final ResponseData responseData;
  final Key componentId;
  final List<MenuItem> items;
  final Request request;
  final String menuComponentId;
  final String templateName;

  OpenScreenPage(
      {Key key,
      this.responseData,
      this.request,
      this.componentId,
      this.title,
      this.items,
      this.menuComponentId,
      this.templateName})
      : super(key: key);

  _OpenScreenPageState createState() => _OpenScreenPageState();
}

class _OpenScreenPageState extends State<OpenScreenPage>
    with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SoScreen screen;
  bool errorMsgShown = false;
  Orientation lastOrientation;
  String title = '';
  String componentId;
  double width;
  double height;
  RestartableTimer _deviceStatusTimer;

  @override
  Widget build(BuildContext context) {
    componentId = widget.componentId
        .toString()
        .replaceAll("[<'", '')
        .replaceAll("'>]", '');

    //update listener context
    if (globals.appListener != null) {
      globals.appListener.fireAfterStartupListener(ApplicationApi(context));
    }

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

    return errorAndLoadingListener(
      BlocListener<ApiBloc, Response>(
          listener: (BuildContext context, Response state) {
            if (state.requestType == RequestType.CLOSE_SCREEN) {
              // Navigator.of(context).pushReplacement(MaterialPageRoute(
              //     settings: RouteSettings(name: '/Menu'),
              //     builder: (_) => MenuPage(
              //           menuItems: globals.items,
              //         )));

              Navigator.of(context).pushReplacementNamed('/menu',
                  arguments: MenuArguments(globals.items, true));
            } else {
              print("*** OpenScreenPage - RequestType: " +
                  state.requestType.toString());

              if (state.requestType == RequestType.DEVICE_STATUS &&
                  state.deviceStatus != null) {
                globals.layoutMode = state.deviceStatus.layoutMode;
                this.setState(() {});
              }

              if (isScreenRequest(state.requestType) &&
                      //state.screenGeneric != null &&
                      !state.loading //&& !state.error
                  ) {
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
                  } else if (state.closeScreenAction != null &&
                      state.responseData.screenGeneric == null) {
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(
                    //     settings: RouteSettings(name: '/Menu'),
                    //     builder: (_) => MenuPage(
                    //           menuItems: globals.items,
                    //         )));

                    Navigator.of(context).pushReplacementNamed('/menu',
                        arguments: MenuArguments(globals.items, true));
                  }
                }

                if (state.requestType == RequestType.OPEN_SCREEN) {
                  if (mounted &&
                      _scaffoldKey.currentState != null &&
                      _scaffoldKey.currentState.isEndDrawerOpen)
                    SchedulerBinding.instance.addPostFrameCallback(
                        (_) => Navigator.of(context).pop());
                  // screen = globals.customScreenManager == null
                  //     ? IScreen(SoComponentCreator(context))
                  //     : globals.customScreenManager.getScreen(
                  //         widget.menuComponentId,
                  //         templateName: widget.templateName);
                  // title = state.action.label;
                  componentId = state.responseData?.screenGeneric?.componentId;
                }

                if (state.responseData.screenGeneric != null &&
                    !state.responseData.screenGeneric.update) {
                  // screen = globals.customScreenManager == null
                  //     ? IScreen(SoComponentCreator(context))
                  //     : globals.customScreenManager.getScreen(
                  //         widget.menuComponentId,
                  //         templateName: widget.templateName);
                  componentId = state.responseData.screenGeneric.componentId;
                }

                if (state.requestType == RequestType.NAVIGATION &&
                    state.responseData.screenGeneric == null) {
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //     settings: RouteSettings(name: '/Menu'),
                  //     builder: (_) => MenuPage(
                  //           menuItems: globals.items,
                  //         )));

                  Navigator.of(context).pushReplacementNamed('/menu',
                      arguments: MenuArguments(globals.items, true));
                }
                screen.update(state.request, state.responseData);
              }
            }
          },
          child: WillPopScope(
            onWillPop: () async {
              Navigation navigation = Navigation(
                  clientId: globals.clientId, componentId: componentId);

              TextUtils.unfocusCurrentTextfield(context);

              Future.delayed(const Duration(milliseconds: 100), () {
                BlocProvider.of<ApiBloc>(context).dispatch(navigation);
              });

              bool close = false;

              await for (Response res
                  in BlocProvider.of<ApiBloc>(context).state) {
                if (res.requestType == RequestType.NAVIGATION) {
                  close = true;
                }
              }

              return close;
            },
            child: BlocBuilder<ApiBloc, Response>(
                condition: (Response previous, Response current) {
              if (previous.requestType == current.requestType) {
                return false;
              }
              return true;
            }, builder: (context, state) {
              if (state.responseData.screenGeneric != null &&
                  !state.responseData.screenGeneric.update) {
                title = state.responseData.screenGeneric.screenTitle;
              }

              Widget child;

              screen.update(state.request, state.responseData);

              if ((globals.applicationStyle != null &&
                  globals.applicationStyle?.desktopIcon != null)) {
                globals.appFrame.setScreen(Container(
                    decoration: BoxDecoration(
                        color: (globals.applicationStyle != null &&
                                globals.applicationStyle.desktopColor != null)
                            ? globals.applicationStyle.desktopColor
                            : null,
                        image: !kIsWeb
                            ? DecorationImage(
                                image: FileImage(File(
                                    '${globals.dir}${globals.applicationStyle.desktopIcon}')),
                                fit: BoxFit.cover)
                            : DecorationImage(
                                image: globals.files.containsKey(
                                        globals.applicationStyle.desktopIcon)
                                    ? MemoryImage(utf8.base64Decode(globals
                                            .files[
                                        globals.applicationStyle.desktopIcon]))
                                    : null,
                                fit: BoxFit.cover,
                              )),
                    child: screen));
                child = globals.appFrame.getWidget();
              } else if ((globals.applicationStyle != null &&
                  globals.applicationStyle?.desktopColor != null)) {
                globals.appFrame.setScreen(Container(
                    decoration: BoxDecoration(
                        color: globals.applicationStyle.desktopColor),
                    child: screen));
                child = globals.appFrame.getWidget();
              } else {
                globals.appFrame.setScreen(screen);
                child = globals.appFrame.getWidget();
              }

              return Scaffold(
                  endDrawer: globals.appFrame.showScreenHeader
                      ? MenuDrawerWidget(
                          menuItems: widget.items,
                          listMenuItems: true,
                          currentTitle: widget.title,
                          groupedMenuMode:
                              (globals.applicationStyle?.menuMode ==
                                          'grid_grouped' ||
                                      globals.applicationStyle?.menuMode ==
                                          'list') &
                                  hasMultipleGroups(),
                        )
                      : null,
                  key: _scaffoldKey,
                  appBar: globals.appFrame.showScreenHeader
                      ? AppBar(
                          backgroundColor: UIData.ui_kit_color_2,
                          actions: <Widget>[
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.ellipsisV),
                              onPressed: () =>
                                  _scaffoldKey.currentState.openEndDrawer(),
                            )
                          ],
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigation navigation = Navigation(
                                  clientId: globals.clientId,
                                  componentId: componentId);

                              TextUtils.unfocusCurrentTextfield(context);

                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                BlocProvider.of<ApiBloc>(context)
                                    .dispatch(navigation);
                              });
                            },
                          ),
                          title: Text(title ?? ''),
                        )
                      : null,
                  body: child);
            }),
          )),
    );
  }

  @override
  void initState() {
    // screen = globals.customScreenManager == null
    //     ? IScreen(SoComponentCreator(context))
    //     : globals.customScreenManager.getScreen(
    //         widget.menuComponentId.toString(),
    //         templateName: globals.currentTempalteName);

    screen = SoScreen(
      componentCreator: SoComponentCreator(),
    );

    globals.currentTempalteName = null;
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  didChangeMetrics() {}

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

  Future<File> openFilePicker(BuildContext context) async {
    File file;
    if (!kIsWeb) {
      await showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 220,
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          Translations.of(context)
                              .text2('Choose file', 'Choose file'),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      IconButton(
                        color: Colors.grey[300],
                        icon: FaIcon(FontAwesomeIcons.timesCircle),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => pick('camera').then((val) async {
                      ImageProperties properties =
                          await FlutterNativeImage.getImageProperties(val.path);
                      File compressedImage =
                          await FlutterNativeImage.compressImage(val.path,
                              quality: 80,
                              targetWidth: globals.uploadPicWidth,
                              targetHeight: (properties.height *
                                      globals.uploadPicWidth /
                                      properties.width)
                                  .round());

                      file = compressedImage;

                      Navigator.of(context).pop();
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FaIcon(
                            FontAwesomeIcons.camera,
                            color: UIData.ui_kit_color_2,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            Translations.of(context).text2('Camera', 'Camera'),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => pick('gallery').then((val) {
                      file = val;
                      Navigator.of(context).pop();
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FaIcon(
                            FontAwesomeIcons.images,
                            color: UIData.ui_kit_color_2,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            Translations.of(context)
                                .text2('Gallery', 'Gallery'),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => pick('file system').then((val) {
                      file = val;
                      Navigator.of(context).pop();
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FaIcon(
                            FontAwesomeIcons.folderOpen,
                            color: UIData.ui_kit_color_2,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            Translations.of(context).text2('Filesystem'),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    } else {
      await showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 120,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          Translations.of(context)
                              .text2('Choose file', 'Choose file'),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      IconButton(
                        color: Colors.grey[300],
                        icon: FaIcon(FontAwesomeIcons.timesCircle),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () => pick('file system').then((val) {
                      file = val;
                      Navigator.of(context).pop();
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FaIcon(
                            FontAwesomeIcons.folderOpen,
                            color: UIData.ui_kit_color_2,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            Translations.of(context).text2('Filesystem'),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    }

    return file;
  }

  Future<File> pick(String type) async {
    File file;

    if (type == 'camera') {
      file = await ImagePicker.pickImage(source: ImageSource.camera);
    } else if (type == 'gallery') {
      file = await ImagePicker.pickImage(source: ImageSource.gallery);
    } else if (type == 'file system') {
      file = await FilePicker.getFile(type: FileType.any);
    }

    return file;
  }
}
