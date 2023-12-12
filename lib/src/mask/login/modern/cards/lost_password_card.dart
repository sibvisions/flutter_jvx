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
import '../../../../util/jvx_colors.dart';
import '../../../../util/widgets/progress/progress_button.dart';
import '../../../state/loading_bar.dart';
import '../../login_page.dart';
import '../modern_login.dart';

class LostPasswordCard extends StatefulWidget {
  final String? errorMessage;

  const LostPasswordCard({
    super.key,
    this.errorMessage,
  });

  @override
  State<LostPasswordCard> createState() => _LostPasswordCardState();
}

class _LostPasswordCardState extends State<LostPasswordCard> {
  final TextEditingController identifierController = TextEditingController();
  ButtonState progressButtonState = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
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
                          FlutterUI.translate("Reset password"),
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
                        child: Text(FlutterUI.translate("Please enter your e-mail address.")),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: identifierController,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.emailAddress,
                            onSubmitted: (_) => _onResetPasswordPressed(),
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.envelope),
                              labelText: "${FlutterUI.translate("E-mail")}/${FlutterUI.translate("Username")}",
                              border: InputBorder.none,
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
                              FlutterUI.translate("Reset Password").toUpperCase(),
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
                              onPressed: () => _onResetPasswordPressed(),
                              state: LoadingBar.maybeOf(context)?.show ?? false
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
    identifierController.dispose();
    super.dispose();
  }

  void resetButton() {
    setState(() => progressButtonState = ButtonState.idle);
  }

  void _onResetPasswordPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doResetPassword(
      identifier: identifierController.text,
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
