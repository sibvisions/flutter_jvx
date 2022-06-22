import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';

import '../../../mixin/ui_service_mixin.dart';
import '../../../model/command/api/change_password_command.dart';

class ChangePassword extends StatelessWidget with ConfigServiceMixin, UiServiceMixin {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  ChangePassword({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: TextField(
                controller: TextEditingController(text: configService.getUserInfo()?.userName),
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
      actions: [
        TextButton(
          onPressed: () => {
            if (newPasswordController.text == repeatPasswordController.text)
              {
                uiService.sendCommand(ChangePasswordCommand(
                    newPassword: newPasswordController.text,
                    password: passwordController.text,
                    reason: 'Change Password Request'))
              }
            else
              {
                uiService.openDialog(pDialogWidget: passwordError(), pIsDismissible: true),
              }
          },
          child: const Text('Change Password'),
        )
      ],
    );
  }

  Widget passwordError() {
    return const AlertDialog(
      title: Text('Error'),
      content: Text("The new passwords dont match!"),
    );
  }
}
