import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'utils/config.dart';

import 'mobile_app.dart';
import 'logic/bloc/api_bloc.dart';
import 'logic/bloc/main_bloc_delegate.dart';
import 'logic/bloc/theme_bloc.dart';
import 'ui/tools/restart.dart';

class ApplicationWidget extends StatelessWidget {
  final Config config;

  const ApplicationWidget({
    Key key,
    this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocSupervisor.delegate = MainBlocDelegate();
    return MultiBlocProvider(
        child: RestartWidget(
            loadConfigBuilder: (bool loadConf) =>
                BlocBuilder<ThemeBloc, ThemeData>(builder: (context, state) {
                  return MobileApp(
                    loadConf,
                    state,
                    config: config,
                  );
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
