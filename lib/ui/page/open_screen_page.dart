import 'dart:async';

import 'package:flutter/material.dart';
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
        body: JVxScreen(this.componentId, this.changedComponents).getWidget(),
      ),
    );
  }
}