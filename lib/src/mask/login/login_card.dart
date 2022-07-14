import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../mixin/config_service_mixin.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/login_command.dart';
import 'remember_me_checkbox.dart';

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
    String? loginTitle = configService.getAppStyle()?['login.title'];

    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              loginTitle ?? configService.getAppName().toUpperCase(),
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: configService.translateText("Username: ")),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: configService.translateText("Password: ")),
              controller: passwordController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Center(
              child: RememberMeCheckbox(
                checkHolder: checkHolder,
              ),
            ),
            ElevatedButton(
              onPressed: _onLoginPressed,
              child: Text(configService.translateText("Login")),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: () => context.beamToNamed("/login/lostPassword"),
                child: Text(configService.translateText("Reset password") + "?"),
              ),
              TextButton.icon(
                onPressed: () => _onSettingsPressed(context: context),
                icon: const FaIcon(FontAwesomeIcons.cogs),
                label: Text(configService.translateText("Settings")),
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
