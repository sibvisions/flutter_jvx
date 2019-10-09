import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/logic/bloc/close_screen_bloc.dart';
import 'package:jvx_mobile_v3/logic/new_bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/new_bloc/error_handler.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/close_screen_view_model.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/close_screen/close_screen.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/ui/widgets/custom_bottom_modal.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

import 'menu_page.dart';

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

class _OpenScreenPageState extends State<OpenScreenPage> {
  bool errorMsgShown = false;
    
  void rebuildOpenScreen(List<ChangedComponent> changedComponents) {
    this.setState(() {
      getIt.get<JVxScreen>("screen").updateComponents(changedComponents);
    });
  }

  void rebuild() {
    this.setState(() {});
  }

  @override
  void initState() {
    setState(() {
      getIt.get<JVxScreen>("screen").componentId = widget.componentId;
      getIt.get<JVxScreen>("screen").context = context;
      getIt.get<JVxScreen>("screen").buttonCallback =
          (List<ChangedComponent> data) {
        if (data != null)
          rebuildOpenScreen(data);
        else
          rebuild();
      };

      getIt.get<JVxScreen>("screen").components = <String, JVxComponent>{};
      getIt.get<JVxScreen>("screen").data = widget.data;
      getIt.get<JVxScreen>("screen").metaData = widget.metaData;
      getIt.get<JVxScreen>("screen").title = widget.title;
      getIt.get<JVxScreen>("screen").updateComponents(widget.changedComponents);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiBloc, Response>(builder: (context, state) {
      if (state != null &&
          !state.loading &&
          !errorMsgShown) {
        errorMsgShown = true;
        Future.delayed(Duration.zero, () => handleError(state, context));
      }

      if (state.requestType == RequestType.CLOSE_SCREEN) {
        Future.delayed(Duration.zero, () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MenuPage(
                  menuItems: globals.items,
                  listMenuItemsInDrawer: false,
                )))
        );
      }

      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          key: widget.componentId,
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(FontAwesomeIcons.ellipsisV),
                onPressed: () => showCustomBottomModalMenu(
                    context, widget.items, widget.componentId),
              )
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                CloseScreen closeScreen = CloseScreen(
                    clientId: globals.clientId,
                    componentId: widget.componentId.toString().replaceAll("[<'", '').replaceAll("'>]", ''),
                    requestType: RequestType.CLOSE_SCREEN);

                BlocProvider.of<ApiBloc>(context).dispatch(closeScreen);
              },
            ),
            title: Text(widget.title),
          ),
          body: getIt.get<JVxScreen>("screen").getWidget(),
        ),
      );
    });
  }
}
