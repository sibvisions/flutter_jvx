import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/error_handler.dart';
import 'package:jvx_mobile_v3/model/api/request/device_Status.dart';
import 'package:jvx_mobile_v3/model/api/request/download.dart';
import 'package:jvx_mobile_v3/model/api/request/navigation.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/request/upload.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/response/screen_generic.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/page/menu_page.dart';
import 'package:jvx_mobile_v3/ui/screen/component_creator.dart';
import 'package:jvx_mobile_v3/ui/screen/i_screen.dart';
import 'package:jvx_mobile_v3/ui/widgets/menu_drawer_widget.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class OpenScreenPage extends StatefulWidget {
  final String title;
  final List<JVxData> data;
  final List<JVxMetaData> metaData;
  final Key componentId;
  final List<MenuItem> items;
  final Request request;
  final ScreenGeneric screenGeneric;
  final String menuComponentId;

  OpenScreenPage(
      {Key key,
      this.screenGeneric,
      this.data,
      this.metaData,
      this.request,
      this.componentId,
      this.title,
      this.items,
      this.menuComponentId})
      : super(key: key);

  _OpenScreenPageState createState() => _OpenScreenPageState();
}

class _OpenScreenPageState extends State<OpenScreenPage>
    with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  IScreen screen;
  bool errorMsgShown = false;
  Orientation lastOrientation;
  String title = '';
  String componentId;

  @override
  Widget build(BuildContext context) {
    componentId = widget.componentId
        .toString()
        .replaceAll("[<'", '')
        .replaceAll("'>]", '');

    if (lastOrientation == null)
      lastOrientation = MediaQuery.of(context).orientation;
    else if (lastOrientation != MediaQuery.of(context).orientation) {
      DeviceStatus status = DeviceStatus(
          screenSize: MediaQuery.of(context).size,
          timeZoneCode: "",
          langCode: "");
      BlocProvider.of<ApiBloc>(context).dispatch(status);
      lastOrientation = MediaQuery.of(context).orientation;
    }

    return errorAndLoadingListener(
      BlocListener<ApiBloc, Response>(
          listener: (BuildContext context, Response state) {
            if (state.requestType == RequestType.CLOSE_SCREEN) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MenuPage(
                        menuItems: globals.items,
                        listMenuItemsInDrawer: false,
                      )));
            } else {
              print("*** OpenScreenPage - RequestType: " +
                  state.requestType.toString());

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
                      state.screenGeneric == null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MenuPage(
                              menuItems: globals.items,
                              listMenuItemsInDrawer: false,
                            )));
                  }
                }

                if (state.requestType == RequestType.OPEN_SCREEN) {
                  if (mounted &&
                      _scaffoldKey.currentState != null &&
                      _scaffoldKey.currentState.isEndDrawerOpen)
                    SchedulerBinding.instance.addPostFrameCallback(
                        (_) => Navigator.of(context).pop());
                  screen = globals.customScreenManager == null ? IScreen(ComponentCreator()) : globals.customScreenManager.getScreen(widget.menuComponentId);
                  // title = state.action.label;
                  componentId = state.screenGeneric.componentId;
                }

                if (state.screenGeneric != null &&
                    !state.screenGeneric.update) {
                  screen = globals.customScreenManager == null ? IScreen(ComponentCreator()) : globals.customScreenManager.getScreen(widget.menuComponentId);
                  componentId = state.screenGeneric.componentId;
                }

                screen.componentScreen.context = context;
                screen.update(state.request, state.jVxData, state.jVxMetaData,
                    state.screenGeneric);
                this.setState(() {});
              }
            }
          },
          child: WillPopScope(
            onWillPop: () async {
              Navigation navigation = Navigation(
                  clientId: globals.clientId, componentId: componentId);
                  
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }

              Future.delayed(const Duration(milliseconds: 10), () {
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
              if (state.screenGeneric != null && !state.screenGeneric.update) {
                title = state.screenGeneric.screenTitle;
              }
              return Scaffold(
                  endDrawer: MenuDrawerWidget(
                    menuItems: widget.items,
                    listMenuItems: true,
                    currentTitle: widget.title,
                  ),
                  key: _scaffoldKey,
                  appBar: AppBar(
                    backgroundColor: UIData.ui_kit_color_2,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(FontAwesomeIcons.ellipsisV),
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

                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }

                        Future.delayed(const Duration(milliseconds: 10), () {
                          BlocProvider.of<ApiBloc>(context)
                              .dispatch(navigation);
                        });
                      },
                    ),
                    title: Text(title ?? ''),
                  ),
                  body: screen.getWidget());
            }),
          )),
    );
  }

  @override
  void initState() {
    screen = globals.customScreenManager == null ? IScreen(ComponentCreator()) : globals.customScreenManager.getScreen(widget.menuComponentId.toString());
    screen.componentScreen.context = context;
    screen.update(
        widget.request, widget.data, widget.metaData, widget.screenGeneric);
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

  Future<File> openFilePicker(BuildContext context) async {
    File file;

    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 220,
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
                      icon: Icon(FontAwesomeIcons.timesCircle),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                GestureDetector(
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
                        Icon(
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
                  onTap: () => pick('gallery').then((val) {
                    file = val;
                    Navigator.of(context).pop();
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.images,
                          color: UIData.ui_kit_color_2,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          Translations.of(context).text2('Gallery', 'Gallery'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
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
                        Icon(
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

    return file;
  }

  Future<File> pick(String type) async {
    File file;

    if (type == 'camera') {
      file = await ImagePicker.pickImage(source: ImageSource.camera);
    } else if (type == 'gallery') {
      file = await ImagePicker.pickImage(source: ImageSource.gallery);
    } else if (type == 'file system') {
      file = await FilePicker.getFile(type: FileType.ANY);
    }

    return file;
  }
}
