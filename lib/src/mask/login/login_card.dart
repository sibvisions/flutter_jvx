import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../mixin/config_service_mixin.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/login_command.dart';
import 'remember_me_checkbox.dart';

class LoginCard extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const LoginCard({Key? key}) : super(key: key);

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> with ConfigServiceGetterMixin, UiServiceGetterMixin {
  /// Controller for username text field
  final TextEditingController usernameController = TextEditingController();

  /// Controller for password text field
  final TextEditingController passwordController = TextEditingController();

  /// Value holder for the checkbox
  late CheckHolder checkHolder =
      CheckHolder(isChecked: getConfigService().getAppConfig()?.uiConfig.rememberMeChecked ?? false);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    String? loginTitle = getConfigService().getAppStyle()?['login.title'];

    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              loginTitle ?? getConfigService().getAppName().toUpperCase(),
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: getConfigService().translateText("Username: ")),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: getConfigService().translateText("Password: ")),
              controller: passwordController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            if (getConfigService().getAppConfig()?.uiConfig.showRememberMe ?? false)
              Center(
                child: RememberMeCheckbox(
                  checkHolder: checkHolder,
                ),
              ),
            ElevatedButton(
              onPressed: _onLoginPressed,
              child: Text(getConfigService().translateText("Login")),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: () => context.beamToNamed("/login/lostPassword"),
                child: Text(getConfigService().translateText("Reset password") + "?"),
              ),
              TextButton.icon(
                onPressed: () => _onSettingsPressed(context: context),
                icon: const FaIcon(FontAwesomeIcons.cogs),
                label: Text(getConfigService().translateText("Settings")),
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
  void _onLoginPressed() {
    getUiService().setRouteContext(pContext: context);

    LoginCommand loginCommand = LoginCommand(
      loginMode: LoginMode.MANUAL,
      userName: usernameController.text,
      password: passwordController.text,
      reason: "LoginButton",
      createAuthKey: checkHolder.isChecked,
    );
    getUiService().sendCommand(loginCommand);
  }

  void _onSettingsPressed({required BuildContext context}) {
    context.beamToNamed("/setting");
  }
}
