import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/inherited/startup_provider.dart';
import 'package:jvx_mobile_v3/logic/bloc/startup_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/startup_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';

enum StartupValidationType { username, password }

class StartupPage extends StatefulWidget {
  StartupPage({Key key}) : super(key: key);

  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> with SingleTickerProviderStateMixin {
  final scaffoldState = GlobalKey<ScaffoldState>();
  StartupBloc startupBloc = new StartupBloc();
  String applicationName = globals.appName;
  StreamSubscription<FetchProcess> apiStreamSubscription;
  AnimationController controller;
  Animation<double> animation;

  Widget startupBuilder() {
    return StreamBuilder<bool>(
      stream: startupBloc.startupResult,
      initialData: false,
      builder: (context, snapshot) => Center(
        child: Image.asset('assets/images/sib_visions.jpg', width: (MediaQuery.of(context).size.width - 50),),
      )
    );
  }

  @override
  void initState() {
    super.initState();
    loadSharedPrefs();
    apiStreamSubscription = apiSubscription(startupBloc.apiResult, context);    
    startupBloc.startupSink.add(
      new StartupViewModel(applicationName: applicationName, layoutMode: 'generic')
    );
  }

  loadSharedPrefs() async {
    await SharedPreferencesHelper().getData().then((prefData) {
      if (prefData['appName'] == 'null' || prefData['appName'] == null || prefData['appName'].isEmpty) {
      } else {
        globals.appName = prefData['appName'];
      }
      if (prefData['baseUrl'] == 'null' || prefData['baseUrl'] == null || prefData['baseUrl'].isEmpty) {
      } else {
        globals.baseUrl = prefData['baseUrl'];
      }
      if (prefData['language'] == 'null' || prefData['language'] == null || prefData['language'].isEmpty) {
      } else {
        globals.language = prefData['language'];
      }
      if (globals.appName == null && globals.baseUrl == null)
        Navigator.pushReplacementNamed(context, '/settings');
    });
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
      backgroundColor: Colors.white,
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