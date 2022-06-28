import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/reset_password_command.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Card to be displayed in app-login for resetting the password
class LostPasswordCard extends StatelessWidget with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for Email/Username text field
  final TextEditingController identifierController = TextEditingController(text: "features");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LostPasswordCard({
    Key? key,
  }) : super(key: key);

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
              "Please enter Email",
              style: Theme.of(context).textTheme.headline5,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "Email: "),
              controller: identifierController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _sendRequest(),
                  child: Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.paperPlane),
                      Padding(padding: EdgeInsets.all(5)),
                      Text("Reset password"),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.all(2)),
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

  /// Sends [ResetPasswordCommand]
  void _sendRequest() {
    ResetPasswordCommand resetPasswordCommand =
        ResetPasswordCommand(reason: "User resets password", identifier: identifierController.text);
    uiService.sendCommand(resetPasswordCommand);
  }
}
