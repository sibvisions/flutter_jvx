import 'package:flutter/material.dart';

import '../../../../models/app/app_state.dart';
import 'login_card.dart';

class LoginWidgets extends StatelessWidget {
  final String username;
  final AppState appState;

  const LoginWidgets({Key key, this.username, this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              LoginCard(
                username: username,
                appState: this.appState,
              )
            ],
          ),
        ),
      ),
    );
  }
}
