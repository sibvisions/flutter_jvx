import 'package:flutter/material.dart';

import '../../../../main.dart';
import '../../../../mixin/config_service_mixin.dart';
import '../../../../mixin/ui_service_mixin.dart';
import '../../../model/command/api/change_password_command.dart';
import '../../../model/command/api/login_command.dart';

class ChangePassword extends StatelessWidget with ConfigServiceGetterMixin, UiServiceGetterMixin {
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
      title: Text(FlutterJVx.translate('Change Password')),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Text(FlutterJVx.translate('Please enter and confirm the new password.')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "${FlutterJVx.translate('Username')}:",
                  enabled: false,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                enabled: password == null,
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: FlutterJVx.translate('Password'),
                  hintText: FlutterJVx.translate('Enter Password'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                obscureText: true,
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: FlutterJVx.translate('Password (new)'),
                  hintText: FlutterJVx.translate('Password (new)'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                obscureText: true,
                controller: repeatPasswordController,
                decoration: InputDecoration(
                  hintText: FlutterJVx.translate('Password (confirm)'),
                  border: const OutlineInputBorder(),
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
    return AlertDialog(
      title: Text(FlutterJVx.translate('Error')),
      content: Text(FlutterJVx.translate("The passwords don't match!")),
    );
  }

  List<Widget>? actionsList(BuildContext context) {
    List<Widget>? widgetList = [];

    if (getConfigService().getUserInfo() != null) {
      widgetList.add(TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(FlutterJVx.translate('Cancel')),
      ));
    }

    widgetList.add(TextButton(
      onPressed: () {
        if (newPasswordController.text == repeatPasswordController.text) {
          if (getConfigService().getUserInfo() == null) {
            getUiService().sendCommand(LoginCommand(
              userName: usernameController.text,
              password: passwordController.text,
              loginMode: LoginMode.CHANGE_PASSWORD,
              newPassword: newPasswordController.text,
              reason: 'Password Expired',
            ));
          } else {
            getUiService().sendCommand(ChangePasswordCommand(
              username: usernameController.text,
              newPassword: newPasswordController.text,
              password: passwordController.text,
              reason: 'Change Password Request',
            ));
          }
        } else {
          getUiService().openDialog(pBuilder: (_) => passwordError(), pIsDismissible: true);
        }
      },
      child: Text(FlutterJVx.translate('Change Password')),
    ));

    return widgetList;
  }
}
