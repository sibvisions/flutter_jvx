import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:jvx_mobile_v3/jvx_mobile.dart';
import 'package:jvx_mobile_v3/logic/bloc/main_bloc_delegate.dart';
import 'package:jvx_mobile_v3/logic/bloc/theme_bloc.dart';
import 'package:jvx_mobile_v3/ui/screen/i_screen.dart';
import 'package:jvx_mobile_v3/ui/tools/restart.dart';
import 'package:jvx_mobile_v3/utils/config.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

import 'logic/bloc/api_bloc.dart';

void main() {
  runApp(JVxStartingWidget());
}

class JVxStartingWidget extends StatelessWidget {
  final IScreen iScreen;
  final Config config;
  final bool package;

  const JVxStartingWidget({
    Key key,
    this.config,
    this.iScreen,
    this.package = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (iScreen != null) {
      globals.customScreen = this.iScreen;
    }
    if (package != null) {
      globals.package = this.package;
    }
    BlocSupervisor.delegate = MainBlocDelegate();
    return MultiBlocProvider(
        child: RestartWidget(
            loadConfigBuilder: (bool loadConf) =>
                BlocBuilder<ThemeBloc, ThemeData>(builder: (context, state) {
                  return JvxMobile(loadConf, state, config: this.config);
                })),
        providers: [
          BlocProvider<ApiBloc>(
            builder: (_) => ApiBloc(),
          ),
          BlocProvider<ThemeBloc>(
            builder: (_) => ThemeBloc(),
          )
        ]);
  }
}
