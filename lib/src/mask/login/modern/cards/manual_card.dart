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
  late final TextEditingController passwordController = TextEditingController();

  ButtonState progressButtonState = ButtonState.idle;

  late final bool showRememberMe;
  late bool rememberMeChecked;
  bool _passwordHidden = true;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: IConfigService().username.value);

    showRememberMe = (IUiService().applicationMetaData.value?.rememberMeEnabled ?? false) ||
        (IConfigService().getAppConfig()?.uiConfig!.showRememberMe ?? false);
    rememberMeChecked = IConfigService().getAppConfig()?.uiConfig!.rememberMeChecked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    bool replaceSettingsWithApps = IUiService().canRouteToAppOverview();

    return Card(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                hintStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
          textTheme: Theme.of(context).textTheme.copyWith(
                titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
          canvasColor: JVxColors.darken(Theme.of(context).colorScheme.background, 0.05),
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
                              color: Theme.of(context).colorScheme.primary,
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
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.user),
                              labelText: FlutterUI.translate("Username"),
                              border: InputBorder.none,
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
                              icon: const FaIcon(FontAwesomeIcons.key),
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
                              state: LoadingBar.maybeOf(context)?.show ?? false
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

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void resetButton() {
    setState(() => progressButtonState = ButtonState.idle);
  }

  Widget _buildCheckbox(BuildContext context, bool value, {required GestureTapCallback onTap}) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                value: value,
                onChanged: (bool? value) => onTap.call(),
              ),
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
