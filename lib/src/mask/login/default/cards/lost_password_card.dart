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

import '../../../../flutter_ui.dart';
import '../../../../model/command/api/login_command.dart';
import '../../login_page.dart';
import '../default_login.dart';

/// Card to be displayed in app-login for resetting the password
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
  /// Controller for Email text field
  final TextEditingController identifierController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          FlutterUI.translate("Reset password"),
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        Text(
          FlutterUI.translate("Please enter your e-mail address."),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        if (widget.errorMessage != null) DefaultLogin.buildErrorMessage(context, widget.errorMessage!),
        if (widget.errorMessage != null) const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          textInputAction: TextInputAction.done,
          controller: identifierController,
          onSubmitted: (_) => _onResetPasswordPressed(),
          decoration: InputDecoration(
            labelText: FlutterUI.translate("E-mail:"),
            hintText: FlutterUI.translate("E-mail"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        _createBottomRow(),
      ],
    );
  }

  @override
  void dispose() {
    identifierController.dispose();
    super.dispose();
  }

  Widget _createBottomRow() {
    Widget okButton = ElevatedButton(
      onPressed: _onResetPasswordPressed,
      child: Text(FlutterUI.translate("OK")),
    );

    Widget backButton = TextButton(
      onPressed: () => LoginPage.changeMode(mode: LoginMode.Manual),
      child: Text(
        FlutterUI.translate("Cancel"),
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: backButton),
        Flexible(child: okButton),
      ],
    );
  }

  void _onResetPasswordPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doResetPassword(
      identifier: identifierController.text,
    ).then((success) {
      if (!success) {
        HapticFeedback.heavyImpact();
      }
    });
  }
}
