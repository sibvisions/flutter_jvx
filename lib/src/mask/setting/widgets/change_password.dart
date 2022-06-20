import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/api/change_password_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';

class ChagePassword extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  ChagePassword({
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
                controller: repeatPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Password (repeat)',
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
                ChangePasswordCommand(
                    newPassword: newPasswordController.text,
                    password: passwordController.text,
                    reason: 'Chage Password Request')
              }
            else
              {
                OpenErrorDialogCommand(
                    message: 'The new Passwords are different!', reason: 'New and repeat Password dont match')
              }
          },
          child: const Text('Change Password'),
        )
      ],
    );
  }
}
