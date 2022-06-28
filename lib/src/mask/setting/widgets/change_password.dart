import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/login_command.dart';

import '../../../mixin/ui_service_mixin.dart';
import '../../../model/command/api/change_password_command.dart';

class ChangePassword extends StatelessWidget with ConfigServiceMixin, UiServiceMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  final String? username;
  final String? password;

  ChangePassword({
    Key? key,
    this.username,
    this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    usernameController.text = username ?? "";
    passwordController.text = password ?? "";

    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Text('Please enter and confirm the new password.'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username:',
                  enabled: false,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                enabled: password == null,
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                obscureText: true,
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password (new)',
                  hintText: 'Password (new)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                obscureText: true,
                controller: repeatPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Password (confirm)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: actionsList(context),
    );
  }

  Widget passwordError() {
    return const AlertDialog(
      title: Text('Error'),
      content: Text("The new passwords dont match!"),
    );
  }

  List<Widget>? actionsList(BuildContext context) {
    List<Widget>? widgetList = [];

    widgetList.add(TextButton(
      onPressed: () => {
        if (newPasswordController.text == repeatPasswordController.text)
          {
            if (configService.getUserInfo() == null)
              {
                uiService.sendCommand(LoginCommand(
                    userName: usernameController.text,
                    password: passwordController.text,
                    loginMode: LoginMode.CHANGE_PASSWORD,
                    newPassword: newPasswordController.text,
                    reason: 'Password Expired'))
              }
            else
              {
                uiService.sendCommand(ChangePasswordCommand(
                    username: usernameController.text,
                    newPassword: newPasswordController.text,
                    password: passwordController.text,
                    reason: 'Change Password Request'))
              }
          }
        else
          {
            uiService.openDialog(pDialogWidget: passwordError(), pIsDismissible: true),
          }
      },
      child: const Text('Change Password'),
    ));

    if (configService.getUserInfo() == null) {
      widgetList.add(TextButton(
        onPressed: () => {context.beamBack()},
        child: const Text('Cancel'),
      ));
    }
    return widgetList;
  }
}
