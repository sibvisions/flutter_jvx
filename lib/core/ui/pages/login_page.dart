import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/theme/theme_manager.dart';
import '../widgets/page/login/login_page_widget.dart';
import '../widgets/util/app_state_provider.dart';

class LoginPage extends StatelessWidget {
  final String lastUsername;

  const LoginPage({Key key, this.lastUsername}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: sl<ThemeManager>().themeData,
      child: BlocProvider<ApiBloc>(
        create: (_) => sl<ApiBloc>(),
        child: Scaffold(
          backgroundColor: AppStateProvider.of(context).appState.applicationStyle?.loginBackground,
          body: LoginPageWidget(),
        ),
      ),
    );
  }
}
