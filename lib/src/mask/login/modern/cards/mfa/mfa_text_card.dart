/*
 * Copyright 2022-2023 SIB Visions GmbH
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

import '../../../../../flutter_ui.dart';
import '../../../../../util/jvx_colors.dart';
import '../../../../../util/widgets/progress/progress_button.dart';
import '../../../../state/loading_bar.dart';
import '../../../login_page.dart';
import '../mfa_card.dart';

class MFATextCard extends StatefulWidget {
  final String? username;
  final String? password;
  final String? errorMessage;

  const MFATextCard({
    super.key,
    required this.username,
    required this.password,
    this.errorMessage,
  });

  @override
  State<MFATextCard> createState() => _MFATextCardState();
}

class _MFATextCardState extends State<MFATextCard> {
  late final TextEditingController codeController = TextEditingController();

  ButtonState progressButtonState = ButtonState.idle;

  Timer? _timerReset;

  bool _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    return MFACard(
      subTitle: "Please enter your confirmation code.",
      onCancel: _onCancelPressed,
      errorMessage: widget.errorMessage,
      child: Column(
        children: [
          Material(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: codeController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onLoginPressed(),
                keyboardType: TextInputType.visiblePassword,
                onTap: resetButton,
                onChanged: (_) => resetButton(),
                decoration: InputDecoration(
                  icon: const FaIcon(FontAwesomeIcons.lock),
                  labelText: FlutterUI.translate("Code"),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  FlutterUI.translate("Confirm").toUpperCase(),
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
                  state: LoadingBar.maybeOf(context)?.show ?? false ? ButtonState.loading : progressButtonState,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void _onCancelPressed() {
    LoginPage.cancelLogin().then((success) {
      if (success) {
        setState(() => progressButtonState = ButtonState.success);
      } else {
        HapticFeedback.heavyImpact();
        setState(() => progressButtonState = ButtonState.fail);
      }
    });
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

  void _onLoginPressed() {
    _isAuthenticating = true;
    _timerReset?.cancel();

    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doMFALogin(
      username: widget.username,
      confirmationCode: codeController.text,
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
