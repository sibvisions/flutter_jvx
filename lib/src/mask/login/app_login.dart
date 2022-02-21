import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/routing/route_to_settings_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/startup_command.dart';

class AppLogin extends StatelessWidget with UiServiceMixin, ConfigServiceMixin {
  AppLogin({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void onLoginPressed() {
    LoginCommand loginCommand = LoginCommand(
        userName: usernameController.text, password: passwordController.text, reason: "LoginButton");
    uiService.sendCommand(loginCommand);
  }

  void onStartUpPressed() {
    StartupCommand startupCommand = StartupCommand(reason: "StartupButton");
    uiService.sendCommand(startupCommand);
  }

  @override
  Widget build(BuildContext context) {
    
    return (Scaffold(
      body: Row(children: [
        Expanded(child: Container()),
        Expanded(
          flex: 8,
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(configService.getAppName()?.toUpperCase() ?? "App Name",
                      style: Theme.of(context).textTheme.headline4,),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          labelText: "Username: "
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Password: "
                      ),
                      controller: passwordController,
                    ),
                    ElevatedButton(
                      onPressed: onLoginPressed,
                      child: const Text("Login"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onStartUpPressed,
                          icon: const FaIcon(FontAwesomeIcons.cogs),
                          label: const Text("Settings"),
                        ),
                      ]
                    ),
                  ],
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                ),
              ),
            ),
          ),
        ),
        Expanded(child: Container())
      ]),
      bottomNavigationBar: Row(
        children: [

        ],
        mainAxisAlignment: MainAxisAlignment.end,
      ),
    ));
  }
}
