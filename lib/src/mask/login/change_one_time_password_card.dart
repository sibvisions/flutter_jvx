import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/login_command.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangeOneTimePasswordCard extends StatelessWidget with UiServiceMixin, ConfigServiceMixin {
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
              configService.translateText("Welcome"),
              style: themeData.textTheme.headline5,
            ),
            Text(
              configService.translateText("Please enter and confirm the new password"),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: InputDecoration(labelText: configService.translateText("Username: ")),
              controller: userNameController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: InputDecoration(labelText: configService.translateText("One time password: ")),
              controller: oneTimeController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: InputDecoration(labelText: configService.translateText("New password: ")),
              controller: newPasswordController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: InputDecoration(labelText: configService.translateText("Confirm new password: ")),
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
                      Text(configService.translateText("Cancel")),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _sendRequest(),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.paperPlane),
                      const Padding(padding: EdgeInsets.all(5)),
                      Text(configService.translateText("Send Request")),
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
      uiService.openDialog(
          pDialogWidget: Text(configService.translateText("The new Passwords do not match!")), pIsDismissible: true);
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
