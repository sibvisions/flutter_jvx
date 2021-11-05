import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/models/events/meta/startup_event.dart';
import 'package:flutter_jvx/src/models/events/ui/login_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_login_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_startup_event.dart';

class Login extends StatelessWidget with OnLoginEvent, OnStartupEvent {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Login({Key? key}) : super(key: key) {
    fireStartupEvent(StartupEvent(origin: this, reason: "Login Widget constructor loaded"));
  }



  void onLoginPressed() {
    var event = LoginEvent(
        username: "features",
        password: "features",
        origin: this,
        reason: "User clicked on Login Button"
    );
    fireLoginEvent(event);
  }


  @override
  Widget build(BuildContext context) {
    return(
      Scaffold(
        body: Row(
          children: [
            Expanded(child: Container()),
            Expanded (
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