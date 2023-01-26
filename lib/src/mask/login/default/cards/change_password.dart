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

import '../../../../flutter_ui.dart';
import '../../../../model/command/api/change_password_command.dart';
import '../../../../service/command/i_command_service.dart';
import '../../../../service/config/config_controller.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../login_page.dart';

class ChangePassword extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  final String? username;
  final String? password;

  final bool asDialog;

  ChangePassword({
    super.key,
    this.username,
    this.password,
  }) : asDialog = false;

  ChangePassword.asDialog({
    super.key,
    this.username,
    this.password,
  }) : asDialog = true;

  @override
  Widget build(BuildContext context) {
    usernameController.text = username ?? "";
    passwordController.text = password ?? "";

    Widget body = Column(
      children: [
        if (!asDialog)
          Text(
            FlutterUI.translate("Change password"),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        if (!asDialog) const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        Text(FlutterUI.translate("Please enter and confirm the new password.")),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          enabled: false,
          controller: usernameController,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Username:"),
            hintText: FlutterUI.translate("Username"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          enabled: password == null,
          obscureText: true,
          controller: passwordController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Password:"),
            hintText: FlutterUI.translate("Password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          obscureText: true,
          controller: newPasswordController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Password (new):"),
            hintText: FlutterUI.translate("New Password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          obscureText: true,
          controller: repeatPasswordController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitNewPassword(),
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Password (confirm):"),
            hintText: FlutterUI.translate("Confirm Password"),
          ),
        ),
        if (!asDialog)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _createButtons(context),
            ),
          )
      ],
    );

    if (asDialog) {
      return AlertDialog(
        title: Text(
          FlutterUI.translate("Change password"),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(child: body),
        contentPadding: const EdgeInsets.all(16.0),
        actions: _createButtons(context),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      );
    } else {
      return body;
    }
  }

  Widget passwordError(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterUI.translate("Error")),
      content: Text(FlutterUI.translate("The passwords are different!")),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(FlutterUI.translate("Ok")),
        ),
      ],
    );
  }

  List<Widget> _createButtons(BuildContext context) {
    List<Widget> widgetList = [];

    if (ConfigController().userInfo.value != null) {
      widgetList.add(TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(FlutterUI.translate("Cancel")),
      ));
    }

    if (!asDialog) {
      widgetList.add(ElevatedButton(
        onPressed: _submitNewPassword,
        child: Text(FlutterUI.translate("OK")),
      ));
    } else {
      widgetList.add(TextButton(
        onPressed: _submitNewPassword,
        child: Text(FlutterUI.translate("OK")),
      ));
    }

    return widgetList;
  }

  void _submitNewPassword() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (newPasswordController.text == repeatPasswordController.text) {
      if (ConfigController().userInfo.value == null) {
        LoginPage.doChangePassword(
          username: usernameController.text,
          password: passwordController.text,
          newPassword: newPasswordController.text,
        ).catchError(IUiService().handleAsyncError);
      } else {
        ICommandService()
            .sendCommand(ChangePasswordCommand(
              username: usernameController.text,
              password: passwordController.text,
              newPassword: newPasswordController.text,
              reason: "Change Password Request",
            ))
            .then((value) => Navigator.of(FlutterUI.getCurrentContext()!).pop())
            .catchError(IUiService().handleAsyncError);
      }
    } else {
      IUiService().openDialog(pBuilder: (context) => passwordError(context), pIsDismissible: true);
    }
  }
}
