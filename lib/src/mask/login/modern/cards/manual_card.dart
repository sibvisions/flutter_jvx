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
import '../../../../config/app_config.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/command/api/login_command.dart';
import '../../../../service/config/i_config_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/jvx_colors.dart';
import '../../../../util/widgets/progress/progress_button.dart';
import '../../../apps/app_overview_page.dart';
import '../../../state/app_style.dart';
import '../../../state/app_style_direct.dart';
import '../../../state/loading_bar.dart';
import '../../login_page.dart';
import '../modern_login.dart';

class ManualCard extends StatefulWidget {
  final bool showSettings;
  final String? errorMessage;

  const ManualCard({
    super.key,
    required this.showSettings,
    this.errorMessage,
  });

  static bool showSettingsInCard(BoxConstraints constraints) =>
      constraints.maxHeight <= 605 || constraints.maxWidth > 1400;

  @override
  State<ManualCard> createState() => _ManualCardState();
}

class _ManualCardState extends State<ManualCard> {
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;

  ButtonState progressButtonState = ButtonState.idle;

  Timer? _timerReset;

  late bool showRememberMe;
  late bool rememberMeChecked;
  late bool useBiometric;

  bool _passwordHidden = true;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();

    IConfigService servConf = IConfigService();

    usernameController = TextEditingController(text: servConf.username.value);
    passwordController = TextEditingController();

    AppStyleDirect appStyle = AppStyle.direct();
    useBiometric = appStyle.styleAsBool(AppStyle.loginBiometric);

    //if we use biometric login -> we don't show remember me because it's implicit
    showRememberMe = !useBiometric
                     && (IUiService().applicationMetaData.value?.rememberMeEnabled ?? false);

    AppConfig? appConf = servConf.getAppConfig();

    //this option is server controlled, but we can disable it
    if (showRememberMe && appConf?.uiConfig!.showRememberMe == false) {
      showRememberMe = false;
    }

    rememberMeChecked = showRememberMe && (appConf?.uiConfig!.rememberMeChecked ?? false);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool replaceSettingsWithApps = IUiService().canRouteToAppOverview();

    return Card(
      color: Theme.of(context).colorScheme.surface.withAlpha(Color.getAlphaFromOpacity(0.9)),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                hintStyle: const TextStyle(fontWeight: FontWeight.w200),
              ),
          textTheme: Theme.of(context).textTheme.copyWith(
                titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
          canvasColor: JVxColors.darken(Theme.of(context).colorScheme.surface, 0.05),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.bold),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width / 10 * 8,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (widget.errorMessage != null)
                      ModernLogin.buildErrorMessage(
                        context,
                        widget.errorMessage!,
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            FlutterUI.translate("Login"),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (widget.showSettings)
                            IconButton(
                              tooltip: FlutterUI.translate(replaceSettingsWithApps ? "Apps" : "Settings"),
                              splashRadius: 30,
                              color: Theme.of(context).textTheme.labelSmall!.color,
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () => replaceSettingsWithApps
                                  ? IUiService().routeToAppOverview()
                                  : IUiService().routeToSettings(),
                              icon: replaceSettingsWithApps
                                  ? const Icon(AppOverviewPage.appsIcon)
                                  : const FaIcon(FontAwesomeIcons.gear),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(FlutterUI.translate("Please enter your username and password.")),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            autocorrect: false,
                            spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                            decoration: InputDecoration(
                              icon: const Icon(Icons.person_outline, size: 22),
                              labelText: FlutterUI.translate("Username"),
                              border: InputBorder.none,
                              suffixIcon: usernameController.text.isNotEmpty
                                  ? ExcludeFocus(
                                      child: IconButton(
                                        tooltip: FlutterUI.translate("Clear"),
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => setState(() => usernameController.clear()),
                                        color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                                        iconSize: FlTextFieldWidget.iconSize,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: passwordController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onLoginPressed(),
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            obscureText: _passwordHidden,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.password, size: 22),
                              labelText: FlutterUI.translate("Password"),
                              border: InputBorder.none,
                              suffixIcon: passwordController.text.isNotEmpty
                                  ? ExcludeFocus(
                                      child: IconButton(
                                        tooltip:
                                            FlutterUI.translate(_passwordHidden ? "Show password" : "Hide password"),
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
                          ),
                        ),
                      ),
                    ),
                    if (showRememberMe)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9.5),
                        child: _buildCheckbox(
                          context,
                          rememberMeChecked,
                          onTap: () => setState(() {
                            resetButton();

                            rememberMeChecked = !rememberMeChecked;
                          }),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              FlutterUI.translate("Login").toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ProgressButton.icon(
                              elevation: 3,
                              maxWidth: 60,
                              minWidth: 60,
                              height: 60,
                              padding: const EdgeInsets.all(16.0),
                              shape: const CircleBorder(),
                              progressIndicatorSize: const Size.square(24.0),
                              progressIndicator: CircularProgressIndicator.adaptive(
                                backgroundColor: JVxColors.toggleColor(Theme.of(context).colorScheme.onPrimary),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                              stateButtons: {
                                ButtonState.idle: const StateButton(
                                  child: IconedButton(
                                    icon: FaIcon(FontAwesomeIcons.arrowRight),
                                  ),
                                ),
                                ButtonState.fail: StateButton(
                                  color: Theme.of(context).colorScheme.error,
                                  textStyle: TextStyle(color: Theme.of(context).colorScheme.onError),
                                  child: const IconedButton(
                                    icon: Icon(Icons.cancel),
                                  ),
                                ),
                              },
                              onPressed: () => _onLoginPressed(),
                              state: (LoadingBar.maybeOf(context)?.show ?? _isAuthenticating)
                                  ? ButtonState.loading
                                  : progressButtonState,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (IUiService().applicationMetaData.value?.lostPasswordEnabled == true)
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => LoginPage.changeMode(mode: LoginMode.LostPassword),
                        child: Text(FlutterUI.translate("Reset password?")),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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

  Widget _buildCheckbox(BuildContext context, bool value, {required GestureTapCallback onTap}) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Row(
            children: [Stack(alignment: Alignment.center, children: [
              if (value == true) ClipOval(
                child: Container(height: 30, width: 30, color: Theme.of(context).colorScheme.primary)),
              Checkbox(
                value: value,
                onChanged: (bool? value) => onTap.call(),
              ),]),
              Text(
                FlutterUI.translate("Remember me?"),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLoginPressed() {
    _isAuthenticating = true;
    _timerReset?.cancel();

    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doLogin(
      username: usernameController.text,
      password: passwordController.text,
      createAuthKey: useBiometric || (showRememberMe && rememberMeChecked),
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
