import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../mixin/config_service_mixin.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/reset_password_command.dart';

/// Card to be displayed in app-login for resetting the password
class LostPasswordCard extends StatelessWidget with UiServiceMixin, ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for Email/Username text field
  final TextEditingController identifierController = TextEditingController(text: "");

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
              configService.translateText("Please enter Email"),
              style: Theme.of(context).textTheme.headline5,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: InputDecoration(labelText: configService.translateText("Email: ")),
              controller: identifierController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _sendRequest(),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.paperPlane),
                      const Padding(padding: EdgeInsets.all(5)),
                      Text(configService.translateText("Reset password")),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.all(2)),
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
        ResetPasswordCommand(reason: "User reset password", identifier: identifierController.text);
    uiService.sendCommand(resetPasswordCommand);
  }
}
