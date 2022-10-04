import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/constants/i_color.dart';
import '../../model/command/api/login_command.dart';
import '../loading_bar.dart';
import 'remember_me_checkbox.dart';

class LoginCard extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const LoginCard({Key? key}) : super(key: key);

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  /// Controller for username text field
  late TextEditingController usernameController;

  /// Controller for password text field
  late TextEditingController passwordController;

  /// Value holder for the checkbox
  late CheckHolder checkHolder;

  ButtonState progressButtonState = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: IConfigService().getUsername());
    passwordController = TextEditingController();
    checkHolder = CheckHolder(isChecked: IConfigService().getAppConfig()?.uiConfig!.rememberMeChecked ?? false);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    String? loginTitle = IConfigService().getAppStyle()['login.title'];

    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loginTitle ?? IConfigService().getAppName()!.toUpperCase(),
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              textInputAction: TextInputAction.next,
              onTap: resetButton,
              onChanged: (_) => resetButton(),
              controller: usernameController,
              decoration: InputDecoration(labelText: "${FlutterJVx.translate("Username")}:"),
            ),
            TextFormField(
              onTap: resetButton,
              onChanged: (_) => resetButton(),
              onEditingComplete: _onLoginPressed,
              controller: passwordController,
              decoration: InputDecoration(labelText: "${FlutterJVx.translate("Password")}:"),
              obscureText: true,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            if (IConfigService().getAppConfig()?.uiConfig!.showRememberMe ?? false)
              Center(
                child: RememberMeCheckbox(
                  checkHolder: checkHolder,
                ),
              ),
            const Padding(padding: EdgeInsets.all(5)),
            ProgressButton.icon(
              radius: 4.0,
              progressIndicator: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation(IColor.toggleColor(Theme.of(context).colorScheme.primary)),
              ),
              textStyle: TextStyle(
                color: progressButtonState != ButtonState.fail ? Theme.of(context).colorScheme.onPrimary : Colors.white,
              ),
              iconedButtons: {
                ButtonState.idle: IconedButton(
                  text: FlutterJVx.translate("Login"),
                  icon: Icon(Icons.login, color: Theme.of(context).colorScheme.onPrimary),
                  color: Theme.of(context).colorScheme.primary,
                ),
                ButtonState.loading: IconedButton(
                  text: FlutterJVx.translate("Loading"),
                  color: Theme.of(context).colorScheme.primary,
                ),
                ButtonState.fail: IconedButton(
                  text: FlutterJVx.translate("Failed"),
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  color: Colors.red.shade600,
                ),
                //Unused but not removable
                ButtonState.success: IconedButton(
                  text: FlutterJVx.translate("Success"),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  color: Colors.green.shade600,
                ),
              },
              onPressed: _onLoginPressed,
              state: LoadingBar.of(context)?.show ?? false ? ButtonState.loading : progressButtonState,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: _getLostPasswordButton()),
              Flexible(
                child: TextButton.icon(
                  onPressed: () => _onSettingsPressed(context: context),
                  icon: const FaIcon(FontAwesomeIcons.gear),
                  label: Text(FlutterJVx.translate("Settings")),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void resetButton() {
    setState(() => progressButtonState = ButtonState.idle);
  }

  Widget _getLostPasswordButton() {
    if (!(IConfigService().getMetaData()?.lostPasswordEnabled == false)) {
      return TextButton(
        onPressed: () => context.beamToNamed("/login/lostPassword"),
        child: Text("${FlutterJVx.translate("Reset password")}?"),
      );
    } else {
      return Container();
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _onLoginPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    IUiService().sendCommand(
        LoginCommand(
          loginMode: LoginMode.MANUAL,
          userName: usernameController.text,
          password: passwordController.text,
          reason: "LoginButton",
          createAuthKey: checkHolder.isChecked,
        ), onError: (error, stackTrace) {
      setState(() => progressButtonState = ButtonState.fail);
      IUiService().handleAsyncError(error, stackTrace);
    });
  }

  void _onSettingsPressed({required BuildContext context}) {
    context.beamToNamed("/settings");
  }
}
