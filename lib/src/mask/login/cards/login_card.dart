import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../flutter_jvx.dart';
import '../../../../services.dart';
import '../../../../util/jvx_colors.dart';
import '../../../model/command/api/login_command.dart';
import '../../../util/loading_handler/progress_button.dart';
import '../../state/app_style.dart';
import '../../state/loading_bar.dart';
import '../login_page.dart';
import '../remember_me_checkbox.dart';

class LoginCard extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const LoginCard({super.key});

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

  bool showRememberMe = false;
  bool _passwordHidden = true;

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
    String? loginTitle = AppStyle.of(context)!.applicationStyle!['login.title'];

    showRememberMe = (IConfigService().getMetaData()?.rememberMeEnabled ?? false) ||
        (IConfigService().getAppConfig()?.uiConfig!.showRememberMe ?? false);
    return Column(
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
          textInputAction: TextInputAction.done,
          onTap: resetButton,
          onChanged: (_) => resetButton(),
          onFieldSubmitted: (_) => _onLoginPressed(),
          controller: passwordController,
          decoration: InputDecoration(
            labelText: "${FlutterJVx.translate("Password")}:",
            suffixIcon: IconButton(
              icon: Icon(
                _passwordHidden ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _passwordHidden = !_passwordHidden;
                });
              },
            ),
          ),
          obscureText: _passwordHidden,
        ),
        const Padding(padding: EdgeInsets.all(5)),
        if (showRememberMe)
          Center(
            child: RememberMeCheckbox(
              checkHolder: checkHolder,
            ),
          ),
        const Padding(padding: EdgeInsets.all(5)),
        ProgressButton.icon(
          radius: 4.0,
          progressIndicator: CircularProgressIndicator.adaptive(
            backgroundColor: JVxColors.toggleColor(Theme.of(context).colorScheme.onPrimary),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
          stateButtons: {
            ButtonState.idle: StateButton(
              child: IconedButton(
                text: FlutterJVx.translate("Login"),
                icon: const Icon(Icons.login),
              ),
            ),
            ButtonState.fail: StateButton(
              color: Colors.red.shade600,
              textStyle: const TextStyle(color: Colors.white),
              child: IconedButton(
                text: FlutterJVx.translate("Failed"),
                icon: const Icon(Icons.cancel),
              ),
            ),
          },
          onPressed: _onLoginPressed,
          state: LoadingBar.of(context)?.show ?? false ? ButtonState.loading : progressButtonState,
        ),
        const Padding(padding: EdgeInsets.all(5)),
        _createBottomRow(),
      ],
    );
  }

  void resetButton() {
    setState(() => progressButtonState = ButtonState.idle);
  }

  Widget? _createLostPasswordButton() {
    if (IConfigService().getMetaData()?.lostPasswordEnabled == true) {
      return TextButton(
        onPressed: () => IUiService().routeToLogin(mode: LoginMode.LostPassword),
        child: Text(
          "${FlutterJVx.translate("Reset password")}?",
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return null;
  }

  Widget _createBottomRow() {
    Widget? lostPasswordButton = _createLostPasswordButton();
    Widget textButton = TextButton.icon(
      onPressed: () => IUiService().routeToSettings(),
      icon: const FaIcon(FontAwesomeIcons.gear),
      label: Text(
        FlutterJVx.translate("Settings"),
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (lostPasswordButton != null) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: lostPasswordButton),
        Flexible(child: textButton),
      ]);
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: textButton,
      );
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _onLoginPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doLogin(
      username: usernameController.text,
      password: passwordController.text,
      createAuthKey: showRememberMe && checkHolder.isChecked,
    ).catchError((error, stackTrace) {
      setState(() => progressButtonState = ButtonState.fail);
      return IUiService().handleAsyncError(error, stackTrace);
    });
  }
}
