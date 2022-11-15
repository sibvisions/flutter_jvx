import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/command/api/login_command.dart';

class ChangeOneTimePasswordCard extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for Email/Username text field
  final TextEditingController userNameController = TextEditingController();

  /// Controller for Email/Username text field
  final TextEditingController oneTimeController = TextEditingController();

  /// Controller for Email/Username text field
  final TextEditingController newPasswordController = TextEditingController();

  /// Controller for Email/Username text field
  final TextEditingController newPasswordConfController = TextEditingController();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ChangeOneTimePasswordCard({super.key});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          FlutterJVx.translate("Welcome"),
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          FlutterJVx.translate("Please enter your one-time password and set a new password"),
        ),
        const Padding(padding: EdgeInsets.all(5)),
        TextFormField(
          decoration: InputDecoration(labelText: "${FlutterJVx.translate("Username")}:"),
          controller: userNameController,
        ),
        const Padding(padding: EdgeInsets.all(5)),
        TextFormField(
          decoration: InputDecoration(labelText: "${FlutterJVx.translate("One-time password")}:"),
          controller: oneTimeController,
        ),
        const Padding(padding: EdgeInsets.all(5)),
        TextFormField(
          decoration: InputDecoration(labelText: "${FlutterJVx.translate("New Password")}:"),
          controller: newPasswordController,
        ),
        const Padding(padding: EdgeInsets.all(5)),
        TextFormField(
          decoration: InputDecoration(labelText: "${FlutterJVx.translate("Confirm new password")}:"),
          controller: newPasswordConfController,
        ),
        const Padding(padding: EdgeInsets.all(5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => context.beamBack(),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.arrowLeft),
                  const Padding(padding: EdgeInsets.all(5)),
                  Text(FlutterJVx.translate("Cancel")),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _sendRequest(),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.paperPlane),
                  const Padding(padding: EdgeInsets.all(5)),
                  Text(FlutterJVx.translate("Send Request")),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _sendRequest() {
    if (newPasswordController.text != newPasswordConfController.text) {
      IUiService().openDialog(
        pBuilder: (_) => Text(FlutterJVx.translate("The new Passwords do not match!")),
        pIsDismissible: true,
      );
    }
    LoginCommand loginCommand = LoginCommand(
      loginMode: LoginMode.CHANGE_ONE_TIME_PASSWORD,
      userName: userNameController.text,
      newPassword: newPasswordController.text,
      password: oneTimeController.text,
      reason: "Password reset",
    );

    IUiService().sendCommand(loginCommand);
  }
}
