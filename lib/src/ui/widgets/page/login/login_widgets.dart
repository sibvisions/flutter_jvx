import 'package:flutter/material.dart';
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart';

import '../../../../models/state/app_state.dart';
import 'login_card.dart';

class LoginWidgets extends StatelessWidget {
  final String username;
  final AppState appState;
  final ApiCubit cubit;
  final LoginMode loginMode;

  const LoginWidgets(
      {Key? key,
      required this.username,
      required this.appState,
      required this.cubit,
      required this.loginMode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              SizedBox(
                  height: 350,
                  child: LoginCard(
                    lastUsername: username,
                    appState: appState,
                    cubit: cubit,
                    loginMode: loginMode,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
