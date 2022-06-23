import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/login_command.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangeOneTimePasswordCard extends StatelessWidget with UiServiceMixin {
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

  ChangeOneTimePasswordCard({Key? key}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Welcome",
              style: Theme.of(context).textTheme.headline5,
            ),
            const Text(
              "Please enter and confirm the new password",
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "Username: "),
              controller: userNameController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "One time password: "),
              controller: oneTimeController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "New password: "),
              controller: newPasswordController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "Confirm new password: "),
              controller: newPasswordConfController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => context.beamBack(),
                  child: Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.arrowLeft),
                      Padding(padding: EdgeInsets.all(5)),
                      Text("Cancel"),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _sendRequest(),
                  child: Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.paperPlane),
                      Padding(padding: EdgeInsets.all(5)),
                      Text("Send Request"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _sendRequest() {
    if (newPasswordController.text != newPasswordConfController.text) {
      uiService.openDialog(pDialogWidget: const Text('The new Passwords do not match!'), pIsDismissible: true);
    }
    LoginCommand loginCommand = LoginCommand(
      loginMode: LoginMode.CHANGE_ONE_TIME_PASSWORD,
      userName: userNameController.text,
      newPassword: newPasswordController.text,
      password: oneTimeController.text,
      reason: "Password reset",
    );

    uiService.sendCommand(loginCommand);
  }
}
