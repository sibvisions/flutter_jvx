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
import '../../../../service/ui/i_ui_service.dart';
import '../../login_page.dart';

class ChangeOneTimePasswordCard extends StatelessWidget {
  /// Controller for username text field
  final TextEditingController userNameController = TextEditingController();

  /// Controller for one time password text field
  final TextEditingController oneTimeController = TextEditingController();

  /// Controller for password text field
  final TextEditingController newPasswordController = TextEditingController();

  /// Controller for confirmPassword text field
  final TextEditingController newPasswordConfController = TextEditingController();

  ChangeOneTimePasswordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          FlutterUI.translate("Change password"),
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        Text(
          FlutterUI.translate("Please enter your one-time password and set a new password."),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          textInputAction: TextInputAction.next,
          controller: userNameController,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Username:"),
            hintText: FlutterUI.translate("Username"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          textInputAction: TextInputAction.next,
          controller: oneTimeController,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("One-time password:"),
            hintText: FlutterUI.translate("One-time password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          textInputAction: TextInputAction.next,
          obscureText: true,
          controller: newPasswordController,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Password (new):"),
            hintText: FlutterUI.translate("New Password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          textInputAction: TextInputAction.done,
          obscureText: true,
          controller: newPasswordConfController,
          onSubmitted: (_) => _onResetOTPPressed(),
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Password (confirm):"),
            hintText: FlutterUI.translate("Confirm Password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        _createBottomRow(),
      ],
    );
  }

  Widget _createBottomRow() {
    Widget okButton = ElevatedButton(
      onPressed: _onResetOTPPressed,
      child: Text(FlutterUI.translate("OK")),
    );

    Widget backButton = TextButton(
      onPressed: () => IUiService().routeToLogin(mode: LoginMode.Manual),
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

  void _onResetOTPPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (newPasswordController.text != newPasswordConfController.text) {
      IUiService().openDialog(
        pBuilder: (_) => Text(FlutterUI.translate("The passwords are different!")),
        pIsDismissible: true,
      );
      return;
    }

    LoginPage.doChangePasswordOTP(
      username: userNameController.text,
      password: oneTimeController.text,
      newPassword: newPasswordController.text,
    ).catchError((error, stackTrace) {
      HapticFeedback.heavyImpact();
      return IUiService().handleAsyncError(error, stackTrace);
    });
  }
}
