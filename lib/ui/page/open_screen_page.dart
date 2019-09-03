import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/logic/bloc/close_screen_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/close_screen_view_model.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class OpenScreenPage extends StatefulWidget {
  final List<ChangedComponent> changedComponents;
  final Key componentId;

  OpenScreenPage({Key key, this.changedComponents, this.componentId}) : super(key: key);

  _OpenScreenPageState createState() => _OpenScreenPageState();
}

class _OpenScreenPageState extends State<OpenScreenPage> {
  @override
  Widget build(BuildContext context) {
    getIt.get<JVxScreen>().componentId = widget.componentId;
    getIt.get<JVxScreen>().context = context;

    for(var i = 0; i < widget.changedComponents.length; i++){
      getIt.get<JVxScreen>().addComponent(widget.changedComponents[i], context);
    }    

    return WillPopScope(
      key: globals.openPageKey,
      onWillPop: () {
        CloseScreenBloc closeScreenBloc = CloseScreenBloc();
        StreamSubscription<FetchProcess> apiStreamSubscription;

        apiStreamSubscription = apiSubscription(closeScreenBloc.apiResult, context);
        closeScreenBloc.closeScreenController.add(
          new CloseScreenViewModel(clientId: globals.clientId, componentId: widget.componentId)
        );

        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('OpenScreen'),
        ),
        body: getIt.get<JVxScreen>().getWidget(),
      ),
    );
  }
}