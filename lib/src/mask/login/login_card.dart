import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/login/remember_me_checkbox.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/login_command.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginCard extends StatelessWidget with ConfigServiceMixin, UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for username text field
  final TextEditingController usernameController = TextEditingController();

  /// Controller for password text field
  final TextEditingController passwordController = TextEditingController();

  /// Value holder for the checkbox
  final CheckHolder checkHolder = CheckHolder(isChecked: false);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginCard({Key? key}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              configService.getAppName().toUpperCase(),
              style: Theme.of(context).textTheme.headline4,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username: "),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Password: "),
              controller: passwordController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
              onPressed: _onLoginPressed,
              child: const Text("Login"),
            ),
            Center(
              child: RememberMeCheckbox(
                checkHolder: checkHolder,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton.icon(
                onPressed: () => context.beamToNamed("/login/lostPassword"),
                icon: const FaIcon(FontAwesomeIcons.question),
                label: const Text("Reset password"),
              ),
              TextButton.icon(
                onPressed: () => _onSettingsPressed(context: context),
                icon: const FaIcon(FontAwesomeIcons.cogs),
                label: const Text("Settings"),
              ),
            ]),
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _onLoginPressed() {
    LoginCommand loginCommand = LoginCommand(
      loginMode: LoginMode.MANUAL,
      userName: usernameController.text,
      password: passwordController.text,
      reason: "LoginButton",
      createAuthKey: checkHolder.isChecked,
    );
    uiService.sendCommand(loginCommand);
  }

  void _onSettingsPressed({required BuildContext context}) {
    context.beamToNamed("/setting");
  }
}
