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

import '../../../../components/editor/text_field/fl_text_field_widget.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/command/api/login_command.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/jvx_colors.dart';
import '../../../../util/widgets/progress/progress_button.dart';
import '../../../state/loading_bar.dart';
import '../../login_page.dart';
import '../modern_login.dart';

class ChangePasswordCard extends StatefulWidget {
  final bool useOTP;
  final String? username;
  final String? password;
  final String? errorMessage;

  const ChangePasswordCard({
    super.key,
    required this.useOTP,
    this.username,
    this.password,
    this.errorMessage,
  });

  @override
  State<ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<ChangePasswordCard> {
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController oneTimePasswordController = TextEditingController();

  ButtonState progressButtonState = ButtonState.idle;

  Timer? _timerReset;

  bool _passwordHidden = true;
  bool _newPasswordHidden = true;
  bool _confirmPasswordHidden = true;

  bool _isChanging = false;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: widget.username);
    passwordController = TextEditingController(text: widget.password);
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          FlutterUI.translate("Change password"),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(FlutterUI.translate(
                          widget.useOTP
                              ? "Please enter your one-time password and set a new password."
                              : "Please enter and confirm the new password.",
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            enabled: widget.useOTP,
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            autocorrect: false,
                            spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.user),
                              labelText: FlutterUI.translate("Username"),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!widget.useOTP)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TextField(
                              enabled: widget.password == null,
                              controller: passwordController,
                              textInputAction: TextInputAction.next,
                              onTap: resetButton,
                              onChanged: (_) => resetButton(),
                              obscureText: _passwordHidden,
                              decoration: InputDecoration(
                                icon: const FaIcon(FontAwesomeIcons.key),
                                labelText: FlutterUI.translate("Password"),
                                border: InputBorder.none,
                                suffixIcon: ExcludeFocus(
                                  child: IconButton(
                                    tooltip: FlutterUI.translate(_passwordHidden ? "Show password" : "Hide password"),
                                    icon: Icon(
                                      _passwordHidden ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(() => _passwordHidden = !_passwordHidden),
                                    color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                                    iconSize: FlTextFieldWidget.iconSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (widget.useOTP)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TextField(
                              controller: oneTimePasswordController,
                              textInputAction: TextInputAction.next,
                              onTap: resetButton,
                              onChanged: (_) => resetButton(),
                              decoration: InputDecoration(
                                icon: const FaIcon(FontAwesomeIcons.userSecret),
                                labelText: FlutterUI.translate("One-time password"),
                                border: InputBorder.none,
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
                            controller: newPasswordController,
                            textInputAction: TextInputAction.next,
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            obscureText: _newPasswordHidden,
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.key),
                              labelText: FlutterUI.translate("New Password"),
                              border: InputBorder.none,
                              suffixIcon: ExcludeFocus(
                                child: IconButton(
                                  tooltip: FlutterUI.translate(_newPasswordHidden ? "Show password" : "Hide password"),
                                  icon: Icon(
                                    _newPasswordHidden ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(() => _newPasswordHidden = !_newPasswordHidden),
                                  color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                                  iconSize: FlTextFieldWidget.iconSize,
                                ),
                              ),
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
                            controller: confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onChangePasswordPressed(),
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            obscureText: _confirmPasswordHidden,
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.key),
                              labelText: FlutterUI.translate("Confirm Password"),
                              border: InputBorder.none,
                              suffixIcon: ExcludeFocus(
                                child: IconButton(
                                  tooltip:
                                      FlutterUI.translate(_confirmPasswordHidden ? "Show password" : "Hide password"),
                                  icon: Icon(
                                    _confirmPasswordHidden ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(() => _confirmPasswordHidden = !_confirmPasswordHidden),
                                  color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                                  iconSize: FlTextFieldWidget.iconSize,
                                ),
                              ),
                            ),
                          ),
                        ),
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
                              FlutterUI.translate("Change Password").toUpperCase(),
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
                              onPressed: () => _onChangePasswordPressed(),
                              state: (LoadingBar.maybeOf(context)?.show ?? _isChanging)
                                  ? ButtonState.loading
                                  : progressButtonState,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => LoginPage.changeMode(mode: LoginMode.Manual),
                      child: Text(FlutterUI.translate("Back")),
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
    _timerReset?.cancel();

    usernameController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    oneTimePasswordController.dispose();

    super.dispose();
  }

  void resetButton() {
    _timerReset?.cancel();

    if (mounted) {
      setState(() {
        _isChanging = false;
        progressButtonState = ButtonState.idle;
      });
    }
  }

  void _resetButtonByTimeout() {
    if (!_isChanging && progressButtonState == ButtonState.fail) {
      resetButton();
    }
  }

  void _onChangePasswordPressed() {
    _isChanging = true;
    _timerReset?.cancel();

    FocusManager.instance.primaryFocus?.unfocus();

    if (newPasswordController.text == confirmPasswordController.text) {
      Future<bool> loginFuture;
      if (widget.useOTP) {
        loginFuture = LoginPage.doChangePasswordOTP(
          username: usernameController.text,
          password: oneTimePasswordController.text,
          newPassword: newPasswordController.text,
        );
      } else {
        loginFuture = LoginPage.doChangePassword(
          username: usernameController.text,
          password: passwordController.text,
          newPassword: newPasswordController.text,
        );
      }
      loginFuture.then((success) {
        if (success) {
          setState(() {
            _isChanging = false;
            progressButtonState = ButtonState.success;
          });
        }
        else {
          _timerReset = Timer(const Duration(seconds: 3), _resetButtonByTimeout);

          HapticFeedback.heavyImpact();

          setState(() {
            _isChanging = false;
            progressButtonState = ButtonState.fail;
          });
        }
      });
    } else {
      _timerReset = Timer(const Duration(seconds: 3), _resetButtonByTimeout);

      HapticFeedback.heavyImpact();

      setState(() {
        _isChanging = false;
        progressButtonState = ButtonState.fail;
      });

      IUiService().openDialog(
        pIsDismissible: true,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterUI.translate("Error")),
          content: Text(FlutterUI.translate("The passwords are different!")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterUI.translate("OK")),
            ),
          ],
        ),
      );
    }
  }
}
