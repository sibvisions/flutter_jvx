import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jvx_mobile_v3/logic/bloc/close_screen_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/close_screen_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class OpenScreenPage extends StatelessWidget {
  final List<ChangedComponent> changedComponents;
  final Key componentId;
  const OpenScreenPage({Key key, this.changedComponents, this.componentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GetIt getIt = GetIt.instance;

    getIt.get<JVxScreen>().componentId = this.componentId;
    getIt.get<JVxScreen>().context = context;

    for(var i = 0; i < changedComponents.length; i++){
      getIt.get<JVxScreen>().addComponent(changedComponents[i], context);
    }    

    return WillPopScope(
      onWillPop: () {
        CloseScreenBloc closeScreenBloc = CloseScreenBloc();
        StreamSubscription<FetchProcess> apiStreamSubscription;

        apiStreamSubscription = apiSubscription(closeScreenBloc.apiResult, context);
        closeScreenBloc.closeScreenController.add(
          new CloseScreenViewModel(clientId: globals.clientId, componentId: this.componentId)
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