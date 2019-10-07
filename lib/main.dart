import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/jvx_mobile.dart';
import 'package:jvx_mobile_v3/ui/screen/component_creator.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';
import 'package:jvx_mobile_v3/ui/tools/restart.dart';

import 'logic/new_bloc/api_bloc.dart';

GetIt getIt = GetIt.instance;

void main() {
  getIt.allowReassignment = true;
  getIt.registerSingleton<JVxScreen>(JVxScreen(ComponentCreator()));
  Injector.configure(Flavor.PRO);
  runApp(new RestartWidget(
    child: MultiBlocProvider(
      child: JvxMobile(),
      providers: [
        BlocProvider<ApiBloc>(
          builder: (_) => ApiBloc(),
        )
      ],
    ),
  ));
}
