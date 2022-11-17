import 'package:flutter/material.dart';

import '../../../../flutter_jvx.dart';
import '../../../../services.dart';
import '../../../model/command/api/change_password_command.dart';
import '../../../model/command/api/login_command.dart';

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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(FlutterJVx.translate("Please enter and confirm the new password.")),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            enabled: false,
            controller: usernameController,
            decoration: InputDecoration(
              labelText: "${FlutterJVx.translate("Username")}:",
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            enabled: password == null,
            obscureText: true,
            controller: passwordController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: "${FlutterJVx.translate("Password")}:",
              hintText: FlutterJVx.translate("Enter Password"),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            obscureText: true,
            controller: newPasswordController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: FlutterJVx.translate("Password (new):"),
              hintText: FlutterJVx.translate("New Password"),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            obscureText: true,
            controller: repeatPasswordController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitNewPassword(),
            decoration: InputDecoration(
              labelText: FlutterJVx.translate("Password (confirm):"),
              hintText: FlutterJVx.translate("New Password"),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (!asDialog)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _createButtons(context),
            ),
          )
      ],
    );

    if (asDialog) {
      return AlertDialog(
        title: Text(FlutterJVx.translate("Change password")),
        content: SingleChildScrollView(child: body),
        actions: _createButtons(context),
      );
    } else {
      return body;
    }
  }

  Widget passwordError(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterJVx.translate("Error")),
      content: Text(FlutterJVx.translate("The passwords don't match!")),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(FlutterJVx.translate("Ok")),
        ),
      ],
    );
  }

  List<Widget> _createButtons(BuildContext context) {
    List<Widget> widgetList = [];

    if (IConfigService().getUserInfo() != null) {
      widgetList.add(TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(FlutterJVx.translate("Cancel")),
      ));
    }

    widgetList.add(TextButton(
      onPressed: () => _submitNewPassword(),
      child: Text(FlutterJVx.translate("Change password")),
    ));

    return widgetList;
  }

  void _submitNewPassword() {
    if (newPasswordController.text == repeatPasswordController.text) {
      if (IConfigService().getUserInfo() == null) {
        IUiService().sendCommand(LoginCommand(
          userName: usernameController.text,
          password: passwordController.text,
          loginMode: LoginMode.ChangePassword,
          newPassword: newPasswordController.text,
          reason: "Password Expired",
        ));
      } else {
        IUiService().sendCommand(ChangePasswordCommand(
          username: usernameController.text,
          newPassword: newPasswordController.text,
          password: passwordController.text,
          reason: "Change Password Request",
        ));
        //TODO close or route
      }
    } else {
      IUiService().openDialog(pBuilder: (context) => passwordError(context), pIsDismissible: true);
    }
  }
}
