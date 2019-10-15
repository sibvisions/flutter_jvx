import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/jvx_mobile.dart';
import 'package:jvx_mobile_v3/logic/bloc/main_bloc_delegate.dart';
import 'package:jvx_mobile_v3/ui/tools/restart.dart';

import 'logic/bloc/api_bloc.dart';

void main() {
  BlocSupervisor.delegate = MainBlocDelegate();
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
