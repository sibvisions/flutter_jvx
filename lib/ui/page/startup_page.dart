import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/inherited/startup_provider.dart';
import 'package:jvx_mobile_v3/logic/bloc/startup_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/startup_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

enum StartupValidationType { username, password }

class StartupPage extends StatefulWidget {
  StartupPage({Key key}) : super(key: key);

  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> with SingleTickerProviderStateMixin {
  final scaffoldState = GlobalKey<ScaffoldState>();
  StartupBloc startupBloc = new StartupBloc();
  String applicationName = 'demo';
  StreamSubscription<FetchProcess> apiStreamSubscription;
  AnimationController controller;
  Animation<double> animation;

  Widget startupBuilder() {
    return StreamBuilder<bool>(
      stream: startupBloc.startupResult,
      initialData: false,
      builder: (context, snapshot) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    apiStreamSubscription = apiSubscription(startupBloc.apiResult, context);
    controller = new AnimationController(
      vsync: this, duration: new Duration(milliseconds: 1500)
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn)
    );
    animation.addListener(() => this.setState(() {}));
    controller.forward();
    startupBloc.startupSink.add(
      new StartupViewModel(applicationName: applicationName)
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    startupBloc?.dispose();
    apiStreamSubscription?.cancel();
    super.dispose();
  }

  Widget startupLoader() => StartupProvider(
    validationErrorCallback: showValidationError,
    child: Scaffold(
      key: scaffoldState,
      backgroundColor: Color(0xffeeeeee),
      body: Center(
        child: startupBuilder()
      ),
    ),
  );

  showValidationError(StartupValidationType type) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text("Something went wrong"),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return startupLoader();
  }
}