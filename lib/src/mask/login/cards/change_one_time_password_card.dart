import 'package:flutter/material.dart';

import '../../../../flutter_jvx.dart';
import '../../../../services.dart';
import '../../../model/command/api/login_command.dart';

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
          FlutterJVx.translate("Change password"),
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        Text(
          FlutterJVx.translate("Please enter your one-time password and set a new password."),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextFormField(
          textInputAction: TextInputAction.next,
          controller: userNameController,
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("Username:"),
            hintText: FlutterJVx.translate("Username"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextFormField(
          textInputAction: TextInputAction.next,
          controller: oneTimeController,
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("One-time password:"),
            hintText: FlutterJVx.translate("One-time password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextFormField(
          textInputAction: TextInputAction.next,
          obscureText: true,
          controller: newPasswordController,
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("Password (new):"),
            hintText: FlutterJVx.translate("New Password"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextFormField(
          textInputAction: TextInputAction.done,
          obscureText: true,
          controller: newPasswordConfController,
          onFieldSubmitted: (_) => _onResetOTPPressed(),
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("Password (confirm):"),
            hintText: FlutterJVx.translate("Confirm Password"),
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
      child: Text(FlutterJVx.translate("OK")),
    );

    Widget backButton = TextButton(
      onPressed: () => IUiService().routeToLogin(mode: LoginMode.Manual),
      child: Text(
        FlutterJVx.translate("Cancel"),
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
        pBuilder: (_) => Text(FlutterJVx.translate("The passwords are different!")),
        pIsDismissible: true,
      );
      return;
    }

    LoginPage.doChangePasswordOTP(
      username: userNameController.text,
      password: oneTimeController.text,
      newPassword: newPasswordController.text,
    ).catchError(IUiService().handleAsyncError);
  }
}
