import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/inherited/startup_provider.dart';
import 'package:jvx_mobile_v3/logic/bloc/startup_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/startup_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/services/shared_preferences/shared_preferences_helper.dart';
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
    TranslationsDelegate().load(new Locale(globals.language));
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
    SharedPreferencesHelper().getAppName().then((val) => val != 'null' ? globals.appName = val : null);
    SharedPreferencesHelper().getBaseUrl().then((val) => val != 'null' ? globals.baseUrl = val : null);
    apiStreamSubscription = apiSubscription(startupBloc.apiResult, context);
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