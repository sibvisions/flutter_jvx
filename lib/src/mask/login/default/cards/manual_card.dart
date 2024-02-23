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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  /// Controller for username text field
  late TextEditingController usernameController;

  /// Controller for password text field
  late TextEditingController passwordController;

  /// Value holder for the checkbox
  late bool rememberMeChecked;

  ButtonState progressButtonState = ButtonState.idle;

  bool showRememberMe = false;
  bool _passwordHidden = true;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: IConfigService().username.value);
    passwordController = TextEditingController();
    rememberMeChecked = IConfigService().getAppConfig()?.uiConfig!.rememberMeChecked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    String? loginTitle = AppStyle.of(context).style(context, 'login.title');

    showRememberMe = (IUiService().applicationMetaData.value?.rememberMeEnabled ?? false) ||
        (IConfigService().getAppConfig()?.uiConfig!.showRememberMe ?? false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loginTitle ?? IConfigService().appName.value?.toUpperCase() ?? "",
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
          decoration: InputDecoration(
            labelText: "${FlutterUI.translate("Username")}:",
            suffixIcon: usernameController.text.isNotEmpty
                ? ExcludeFocus(
                    child: IconButton(
                      tooltip: FlutterUI.translate("Clear"),
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => usernameController.clear()),
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
          state: LoadingBar.maybeOf(context)?.show ?? false ? ButtonState.loading : progressButtonState,
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

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void resetButton() {
    setState(() => progressButtonState = ButtonState.idle);
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
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doLogin(
      username: usernameController.text,
      password: passwordController.text,
      createAuthKey: showRememberMe && rememberMeChecked,
    ).then((success) {
      if (success) {
        setState(() => progressButtonState = ButtonState.success);
      } else {
        HapticFeedback.heavyImpact();
        setState(() => progressButtonState = ButtonState.fail);
      }
    });
  }
}
