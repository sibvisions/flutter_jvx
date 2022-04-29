import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  ChangeOneTimePasswordCard({
    Key? key
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Please enter Email",
              style: Theme.of(context).textTheme.headline5,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "Username: "),
              controller: userNameController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "One time password: "),
              controller: userNameController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "New password: "),
              controller: userNameController,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              decoration: const InputDecoration(labelText: "Confirm new password: "),
              controller: userNameController,
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

  }
}
