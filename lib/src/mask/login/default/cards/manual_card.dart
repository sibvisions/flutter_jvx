/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../components.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/command/api/login_command.dart';
import '../../../../service/config/i_config_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/jvx_colors.dart';
import '../../../../util/widgets/progress/progress_button.dart';
import '../../../apps/app_overview_page.dart';
import '../../../state/app_style.dart';
import '../../../state/loading_bar.dart';
import '../../login_page.dart';
import '../default_login.dart';
import '../remember_me_checkbox.dart';

class ManualCard extends StatefulWidget {
  final String? errorMessage;

  const ManualCard({
    super.key,
    this.errorMessage,
  });

  @override
  State<ManualCard> createState() => _ManualCardState();
}

class _ManualCardState extends State<ManualCard> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  ButtonState progressButtonState = ButtonState.idle;

  Timer? _timerReset;

  late bool showRememberMe;
  late bool rememberMeChecked;
  bool _passwordHidden = true;

  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: IConfigService().username.value);
    passwordController = TextEditingController();

    showRememberMe = IUiService().applicationMetaData.value?.rememberMeEnabled ?? false;

    //this option is server controlled, but we can disable it
    if (showRememberMe && IConfigService().getAppConfig()?.uiConfig!.showRememberMe == false) {
      showRememberMe = false;
    }

    rememberMeChecked = IConfigService().getAppConfig()?.uiConfig!.rememberMeChecked ?? false;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStyle.of(context).style(context, 'login.title') ?? IConfigService().appName.value?.toUpperCase() ?? "",
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        if (widget.errorMessage != null) DefaultLogin.buildErrorMessage(context, widget.errorMessage!),
        TextField(
          textInputAction: TextInputAction.next,
          onTap: resetButton,
          onChanged: (_) => resetButton(),
          controller: usernameController,
          autocorrect: false,
          spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
          decoration: InputDecoration(
            labelText: "${FlutterUI.translate("Username")}:",
            suffixIcon: usernameController.text.isNotEmpty
                ? ExcludeFocus(
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: FlutterUI.translate("Clear"),
                      onPressed: () => setState(() => usernameController.clear()),
                      color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                      iconSize: FlTextFieldWidget.iconSize,
                    ),
                  )
                : null,
          ),
        ),
        TextField(
          textInputAction: TextInputAction.done,
          onTap: resetButton,
          onChanged: (_) => resetButton(),
          onSubmitted: (_) => _onLoginPressed(),
          controller: passwordController,
          decoration: InputDecoration(
            labelText: "${FlutterUI.translate("Password")}:",
            suffixIcon: passwordController.text.isNotEmpty
                ? ExcludeFocus(
                    child: IconButton(
                      tooltip: FlutterUI.translate(_passwordHidden ? "Show password" : "Hide password"),
                      icon: Icon(
                        _passwordHidden ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _passwordHidden = !_passwordHidden),
                      color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                      iconSize: FlTextFieldWidget.iconSize,
                    ),
                  )
                : null,
          ),
          obscureText: _passwordHidden,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        if (showRememberMe)
          Center(
            child: RememberMeCheckbox(
              rememberMeChecked,
              onToggle: () => setState(() => rememberMeChecked = !rememberMeChecked),
            ),
          ),
        if (!showRememberMe)
          const SizedBox(height: 25),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        ProgressButton.icon(
          radius: 4.0,
          progressIndicator: CircularProgressIndicator.adaptive(
            backgroundColor: JVxColors.toggleColor(Theme.of(context).colorScheme.onPrimary),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
          stateButtons: {
            ButtonState.idle: StateButton(
              child: IconedButton(
                text: FlutterUI.translate("Login"),
                icon: const Icon(Icons.login),
              ),
            ),
            ButtonState.fail: StateButton(
              color: Theme.of(context).colorScheme.error,
              textStyle: TextStyle(color: Theme.of(context).colorScheme.onError),
              child: IconedButton(
                text: FlutterUI.translate("Failed"),
                icon: const Icon(Icons.cancel),
              ),
            ),
          },
          onPressed: _onLoginPressed,
          state: (LoadingBar.maybeOf(context)?.show ?? _isAuthenticating) ? ButtonState.loading : progressButtonState,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        if (IUiService().applicationMetaData.value?.lostPasswordEnabled == true)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => LoginPage.changeMode(mode: LoginMode.LostPassword),
              child: Text(
                FlutterUI.translate("Reset password?"),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        _createBottomRow(),
      ],
    );
  }

  void resetButton() {
    _timerReset?.cancel();

    setState(() {
      _isAuthenticating = false;
      progressButtonState = ButtonState.idle;
    });
  }

  void _resetButtonByTimeout() {
    if (!_isAuthenticating && progressButtonState == ButtonState.fail) {
      resetButton();
    }
  }

  Widget _createBottomRow() {
    bool replaceSettingsWithApps = IUiService().canRouteToAppOverview();

    Widget textButton = TextButton.icon(
      onPressed: () => replaceSettingsWithApps ? IUiService().routeToAppOverview() : IUiService().routeToSettings(),
      icon: replaceSettingsWithApps ? const Icon(AppOverviewPage.appsIcon) : const FaIcon(FontAwesomeIcons.gear),
      label: Text(
        FlutterUI.translate(replaceSettingsWithApps ? "Apps" : "Settings"),
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Align(
      alignment: Alignment.centerRight,
      child: textButton,
    );
  }

  void _onLoginPressed() {
    _isAuthenticating = true;
    _timerReset?.cancel();

    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doLogin(
      username: usernameController.text,
      password: passwordController.text,
      createAuthKey: showRememberMe && rememberMeChecked,
    ).then((success) {
      if (success) {
        setState(() {
          _isAuthenticating = false;
          progressButtonState = ButtonState.success;
        });
      } else {
        HapticFeedback.heavyImpact();

        _timerReset = Timer(const Duration(seconds: 3), _resetButtonByTimeout);

        setState(() {
          _isAuthenticating = false;
          progressButtonState = ButtonState.fail;
        });
      }
    });
  }
}
