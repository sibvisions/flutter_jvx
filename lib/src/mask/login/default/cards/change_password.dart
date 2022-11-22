import 'package:flutter/material.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../../services.dart';
import '../../../../model/command/api/change_password_command.dart';

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
            FlutterJVx.translate("Change password"),
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        if (!asDialog) const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        Text(FlutterJVx.translate("Please enter and confirm the new password.")),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          enabled: false,
          controller: usernameController,
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("Username:"),
            hintText: FlutterJVx.translate("Username"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          enabled: password == null,
          obscureText: true,
          controller: passwordController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("Password:"),
            hintText: FlutterJVx.translate("Password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          obscureText: true,
          controller: newPasswordController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("Password (new):"),
            hintText: FlutterJVx.translate("New Password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          obscureText: true,
          controller: repeatPasswordController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitNewPassword(),
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("Password (confirm):"),
            hintText: FlutterJVx.translate("Confirm Password"),
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
          FlutterJVx.translate("Change password"),
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
      title: Text(FlutterJVx.translate("Error")),
      content: Text(FlutterJVx.translate("The passwords are different!")),
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

    if (!asDialog) {
      widgetList.add(ElevatedButton(
        onPressed: _submitNewPassword,
        child: Text(FlutterJVx.translate("OK")),
      ));
    } else {
      widgetList.add(TextButton(
        onPressed: _submitNewPassword,
        child: Text(FlutterJVx.translate("OK")),
      ));
    }

    return widgetList;
  }

  void _submitNewPassword() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (newPasswordController.text == repeatPasswordController.text) {
      if (IConfigService().getUserInfo() == null) {
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
            .then((value) => Navigator.of(FlutterJVx.getCurrentContext()!).pop())
            .catchError(IUiService().handleAsyncError);
      }
    } else {
      IUiService().openDialog(pBuilder: (context) => passwordError(context), pIsDismissible: true);
    }
  }
}
