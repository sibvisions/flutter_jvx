import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';

import '../../../injection_container.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/theme/theme_manager.dart';
import '../widgets/page/login/login_page_widget.dart';

class LoginPage extends StatelessWidget {
  static const String route = '/login';

  final String lastUsername;
  final AppState appState;

  const LoginPage({Key key, this.lastUsername, @required this.appState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: sl<ThemeManager>().themeData,
      child: BlocProvider<ApiBloc>(
        create: (_) => sl<ApiBloc>(),
        child: Scaffold(
            backgroundColor: appState.applicationStyle?.loginBackground,
            body: LoginPageWidget(
              lastUsername: lastUsername,
              appState: appState,
            )),
      ),
    );
  }
}
