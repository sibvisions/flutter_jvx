import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/error_handler.dart';
import 'package:jvx_mobile_v3/model/api/request/close_screen.dart';
import 'package:jvx_mobile_v3/model/api/request/device_Status.dart';
import 'package:jvx_mobile_v3/model/api/request/navigation.dart';
import 'package:jvx_mobile_v3/model/api/request/open_screen.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/page/menu_page.dart';
import 'package:jvx_mobile_v3/ui/screen/component_creator.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/ui/widgets/menu_drawer_widget.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class OpenScreenPage extends StatefulWidget {
  final String title;
  final List<ChangedComponent> changedComponents;
  final List<JVxData> data;
  final List<JVxMetaData> metaData;
  final Key componentId;
  final List<MenuItem> items;

  OpenScreenPage(
      {Key key,
      this.changedComponents,
      this.data,
      this.metaData,
      this.componentId,
      this.title,
      this.items})
      : super(key: key);

  _OpenScreenPageState createState() => _OpenScreenPageState();
}

class _OpenScreenPageState extends State<OpenScreenPage>
    with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  JVxScreen screen = JVxScreen(ComponentCreator());
  bool errorMsgShown = false;
  Orientation lastOrientation;
  String title;

  @override
  Widget build(BuildContext context) {
    title = widget.title;

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

    return BlocBuilder<ApiBloc, Response>(condition: (previousState, state) {
      return previousState.hashCode != state.hashCode;
    }, builder: (context, state) {
      print(
          "*** OpenScreenPage - RequestType: " + state.requestType.toString());

      if (state != null &&
          state.loading &&
          state.requestType == RequestType.LOADING) {
        SchedulerBinding.instance
            .addPostFrameCallback((_) => showProgress(context));
      }

      if (state != null &&
          !state.loading &&
          state.requestType != RequestType.LOADING) {
        SchedulerBinding.instance
            .addPostFrameCallback((_) => hideProgress(context));
      }

      if (state != null && !state.loading && !errorMsgShown) {
        SchedulerBinding.instance.addPostFrameCallback(
            (_) => errorMsgShown = handleError(state, context));
      }

      if (state.requestType == RequestType.CLOSE_SCREEN) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MenuPage(
                    menuItems: globals.items,
                    listMenuItemsInDrawer: false,
                  )));
        });
      }

      if (isScreenRequest(state.requestType) &&
          state.screenGeneric != null &&
          !state.loading &&
          !state.error) {

        if (state.requestType == RequestType.OPEN_SCREEN) {
          if (mounted && _scaffoldKey.currentState != null && _scaffoldKey.currentState.isEndDrawerOpen)
            SchedulerBinding.instance.addPostFrameCallback((_) => Navigator.of(context).pop());
          screen = JVxScreen(ComponentCreator());
          title = state.action.label;
        }
        screen.context = context;
        screen.update(state.request, state.jVxData, state.jVxMetaData,
            state.screenGeneric);
      }

      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            endDrawer: MenuDrawerWidget(
              menuItems: widget.items,
              listMenuItems: true,
              currentScreen: widget.componentId,
            ),
            key: _scaffoldKey,
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(FontAwesomeIcons.ellipsisV),
                  onPressed: () => _scaffoldKey.currentState.openEndDrawer(),
                )
              ],
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigation navigation = Navigation(
                    clientId: globals.clientId,
                    componentId: widget.componentId
                        .toString()
                        .replaceAll("[<'", '')
                        .replaceAll("'>]", ''),
                  );

                  BlocProvider.of<ApiBloc>(context).dispatch(navigation);
                },
              ),
              title: Text(title),
            ),
            body: screen.getWidget()),
      );
    });
  }

  @override
  void initState() {
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
}
