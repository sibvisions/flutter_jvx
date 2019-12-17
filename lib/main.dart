import 'package:bloc/bloc.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/jvx_mobile.dart';
import 'package:jvx_mobile_v3/logic/bloc/main_bloc_delegate.dart';
import 'package:jvx_mobile_v3/ui/tools/restart.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

import 'logic/bloc/api_bloc.dart';

void main() {
  BlocSupervisor.delegate = MainBlocDelegate();
  runApp(DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brigthness) => new ThemeData(
          primaryColor: UIData.ui_kit_color_2,
          primarySwatch: UIData.ui_kit_color_2,
          fontFamily: UIData.ralewayFont),
      themedWidgetBuilder: (context, theme) {
        return MultiBlocProvider(
          child: RestartWidget(
              loadConfigBuilder: (bool loadConf) => JvxMobile(loadConf, theme)),
          providers: [
            BlocProvider<ApiBloc>(
              builder: (_) => ApiBloc(),
            )
          ],
        );
      }));
}
