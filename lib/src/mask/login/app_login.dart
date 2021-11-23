import 'dart:developer';

import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter/material.dart';

class AppLogin extends StatelessWidget with UiServiceMixin{
  AppLogin({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  void onLoginPressed() {
    uiService.login("features", "features");
  }

  void onStartUpPressed() {
    uiService.startUp();
  }


  @override
  Widget build(BuildContext context) {
    return (
        Scaffold(
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
        )
    );
  }
}
