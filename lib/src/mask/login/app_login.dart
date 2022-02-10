import 'package:flutter/material.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/startup_command.dart';

class AppLogin extends StatelessWidget with UiServiceMixin {
  AppLogin({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void onLoginPressed() {
    LoginCommand loginCommand = LoginCommand(userName: "features", password: "features", reason: "LoginButton");
    uiService.sendCommand(loginCommand);
  }

  void onStartUpPressed() {
    StartupCommand startupCommand = StartupCommand(reason: "StartupButton");
    uiService.sendCommand(startupCommand);
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: Row(
        children: [
          Expanded(child: Container()),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: usernameController,
                ),
                TextFormField(
                  controller: passwordController,
                ),
                ElevatedButton(
                  onPressed: onLoginPressed,
                  child: const Text("Login"),
                ),
                ElevatedButton(
                  onPressed: onStartUpPressed,
                  child: const Text("StartUp"),
                ),
              ],
            ),
          ),
          Expanded(child: Container())
        ],
      ),
    ));
  }
}
