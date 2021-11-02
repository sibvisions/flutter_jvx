import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/util/mixin/service/api_service_mixin.dart';

class Login extends StatelessWidget with ApiServiceMixin {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Login({Key? key}) : super(key: key) {
     var res = apiRepository.startUp();
     apiController.determineResponse(res);
  }

  void onLoginPressed() {
     var response = apiRepository.login(
         "features",
         "features"
     );
     apiController.determineResponse(response);
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