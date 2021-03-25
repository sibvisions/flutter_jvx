import 'package:flutter/material.dart';

import '../../../../models/state/app_state.dart';
import 'login_card.dart';

class LoginWidgets extends StatelessWidget {
  final String username;
  final AppState appState;

  const LoginWidgets({Key? key, required this.username, required this.appState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100,),
              SizedBox(
                  height: 350,
                  child: LoginCard(lastUsername: username, appState: appState))
            ],
          ),
        ),
      ),
    );
  }
}
