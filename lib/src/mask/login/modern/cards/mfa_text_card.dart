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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../flutter_ui.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/jvx_colors.dart';
import '../../../../util/progress/progress_button.dart';
import '../../../state/loading_bar.dart';
import '../../login_page.dart';
import 'mfa_card.dart';

class MFATextCard extends StatefulWidget {
  final String? username;
  final String? password;

  const MFATextCard({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<MFATextCard> createState() => _MFATextCardState();
}

class _MFATextCardState extends State<MFATextCard> {
  late final TextEditingController codeController = TextEditingController();

  ButtonState progressButtonState = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    return MFACard(
      subTitle: "Please enter your confirmation code.",
      onCancel: _onCancelPressed,
      child: Column(
        children: [
          Material(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: codeController,
                textInputAction: TextInputAction.next,
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
                      color: Colors.red.shade600,
                      textStyle: const TextStyle(color: Colors.white),
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

  void _onCancelPressed() {
    LoginPage.cancelLogin().catchError((error, stackTrace) {
      setState(() => progressButtonState = ButtonState.fail);
      return IUiService().handleAsyncError(error, stackTrace);
    });
  }

  void resetButton() {
    setState(() => progressButtonState = ButtonState.idle);
  }

  void _onLoginPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doMFALogin(
      username: widget.username,
      confirmationCode: codeController.text,
    ).catchError((error, stackTrace) {
      setState(() => progressButtonState = ButtonState.fail);
      return IUiService().handleAsyncError(error, stackTrace);
    });
  }
}
